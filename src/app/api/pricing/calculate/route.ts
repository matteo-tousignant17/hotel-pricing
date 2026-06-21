import { NextResponse } from "next/server";
import { getServerClient } from "@/lib/supabase-server";

const TIER_BASELINE_OCC: Record<string, number> = {
  luxury: 0.72,
  upscale: 0.73,
  midscale: 0.78,
  budget: 0.82,
};

const DEFAULT_WEIGHTS: Record<string, number> = {
  w_day_of_week: 1.0,
  w_season: 1.0,
  w_lead_time: 1.0,
  w_event: 1.0,
  w_demand_pickup: 1.0,
  w_comp_set: 1.0,
};

function round2(n: number) {
  return Math.round(n * 100) / 100;
}

function dateInRange(
  month: number, day: number,
  sMonth: number, sDay: number,
  eMonth: number, eDay: number
): boolean {
  const check = month * 100 + day;
  const start = sMonth * 100 + sDay;
  const end = eMonth * 100 + eDay;
  if (start <= end) return check >= start && check <= end;
  return check >= start || check <= end; // wraps year (e.g. ski_peak Dec–Mar)
}

function eventEffect(impact: string): number {
  return ({ citywide: 0.30, high: 0.15, medium: 0.08, low: 0.03 } as Record<string, number>)[impact] ?? 0;
}

export async function POST(req: Request) {
  const body = await req.json();
  const {
    hotel_id,
    room_type_id,
    stay_date,
    lead_time_days = 14,
    length_of_stay = 1,
    rate_channel = "direct",
    custom_weights,
    market_segment = "transient",
    contract_type = "corporate_lnr",
  } = body;

  if (!hotel_id || !room_type_id || !stay_date) {
    return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
  }

  const supabase = getServerClient();
  const weights = { ...DEFAULT_WEIGHTS, ...(custom_weights ?? {}) };

  // Parallel batch 1: hotel, room type, seasons, lead time tiers, events, occupancy, comp set IDs
  const [hotelRes, roomRes, seasonsRes, ltRes, eventsRes, occRes, compRes] = await Promise.all([
    supabase.from("hotels").select("id, brand_tier, neighborhood").eq("id", hotel_id).single(),
    supabase.from("room_types").select("base_rate").eq("id", room_type_id).eq("hotel_id", hotel_id).single(),
    supabase.from("season_definitions").select("month_start, day_start, month_end, day_end, demand_index"),
    supabase.from("lead_time_tiers").select("days_min, days_max, rate_multiplier").order("days_min"),
    supabase.from("events").select("demand_impact, affected_neighborhoods").lte("start_date", stay_date).gte("end_date", stay_date),
    supabase.from("rate_calendar").select("occupancy_pct").eq("hotel_id", hotel_id).eq("stay_date", stay_date).eq("rate_channel", "direct").limit(1),
    supabase.from("comp_sets").select("comp_hotel_id").eq("hotel_id", hotel_id),
  ]);

  if (!hotelRes.data || !roomRes.data) {
    return NextResponse.json({ error: "Hotel or room type not found" }, { status: 404 });
  }

  const hotel = hotelRes.data;
  const baseRate = Number(roomRes.data.base_rate);

  // Parse stay date
  const d = new Date(stay_date + "T00:00:00");
  const month = d.getMonth() + 1;
  const day = d.getDate();
  const dow = d.getDay(); // 0=Sun, 5=Fri, 6=Sat

  // --- Day of week ---
  const rawDow = dow === 5 || dow === 6 ? 0.12 : dow === 0 ? 0.05 : 0.0;
  let adjDayOfWeek = round2(baseRate * weights.w_day_of_week * rawDow);

  // --- Season ---
  const season = (seasonsRes.data ?? []).find((s) =>
    dateInRange(month, day, s.month_start, s.day_start, s.month_end, s.day_end)
  );
  const rawSeason = season ? Number(season.demand_index) - 1.0 : 0.05;
  let adjSeason = round2(baseRate * weights.w_season * rawSeason);

  // --- Lead time ---
  const ltTier = (ltRes.data ?? []).find(
    (t) => t.days_min <= lead_time_days && (t.days_max == null || lead_time_days <= t.days_max)
  );
  const rawLt = ltTier ? Number(ltTier.rate_multiplier) - 1.0 : 0.0;
  let adjLeadTime = round2(baseRate * weights.w_lead_time * rawLt);

  // --- Length of stay ---
  const adjLos = length_of_stay >= 7 ? round2(baseRate * -0.10) : length_of_stay >= 3 ? round2(baseRate * -0.05) : 0;

  // --- Events ---
  const matchingEvents = (eventsRes.data ?? []).filter((e) => {
    const affected: string[] = e.affected_neighborhoods ?? [];
    return (
      e.demand_impact === "citywide" ||
      affected.length === 0 ||
      (hotel.neighborhood && affected.includes(hotel.neighborhood))
    );
  });
  const rawEvent = matchingEvents.length > 0
    ? Math.max(...matchingEvents.map((e) => eventEffect(e.demand_impact)))
    : 0;
  let adjEvent = round2(baseRate * weights.w_event * rawEvent);

  // --- Demand pickup ---
  const occupancyPct =
    occRes.data?.[0]?.occupancy_pct != null
      ? Number(occRes.data[0].occupancy_pct)
      : TIER_BASELINE_OCC[hotel.brand_tier ?? ""] ?? 0.73;
  const baseline = TIER_BASELINE_OCC[hotel.brand_tier ?? ""] ?? 0.73;
  const delta = occupancyPct - baseline;
  const rawDemand =
    delta >= 0.18 ? 0.12 : delta >= 0.10 ? 0.07 : delta >= 0.04 ? 0.03
    : delta >= -0.04 ? 0 : delta >= -0.10 ? -0.03 : -0.06;
  let adjDemandPickup = round2(baseRate * weights.w_demand_pickup * rawDemand);

  // --- Comp set (one more query if comp hotels exist) ---
  let adjCompSet = 0;
  const compIds = (compRes.data ?? []).map((r) => r.comp_hotel_id);
  if (compIds.length > 0) {
    const ratesRes = await supabase
      .from("market_rates")
      .select("rate")
      .in("hotel_id", compIds)
      .eq("stay_date", stay_date)
      .eq("rate_channel", "ota");
    const rates = (ratesRes.data ?? []).map((r) => Number(r.rate)).filter((r) => r > 0);
    if (rates.length > 0) {
      const avgCompDirect = rates.reduce((s, r) => s + r, 0) / rates.length / 1.15;
      const rawComp = Math.max(-0.20, Math.min(0.20, (avgCompDirect - baseRate) / baseRate)) * 0.35;
      adjCompSet = round2(baseRate * weights.w_comp_set * rawComp);
    }
  }

  // --- Channel ---
  let adjChannel =
    rate_channel === "ota" ? round2(baseRate * 0.15)
    : rate_channel === "corporate" ? round2(baseRate * -0.10)
    : 0;

  // --- Market segment overrides ---
  let adjSegment = 0;
  if (market_segment === "group") {
    // Groups don't benefit from advance booking and span weekdays — suppress both
    adjDayOfWeek = 0;
    adjLeadTime = 0;
    // Displacement discount: smaller when event compression exists, larger in slow periods
    const groupDiscountPct =
      rawEvent >= 0.15 ? 0.05 : rawSeason > 0.15 ? 0.12 : rawSeason > 0 ? 0.20 : 0.27;
    adjSegment = round2(baseRate * -groupDiscountPct);
  } else if (market_segment === "contract") {
    // Contracted rates are pre-set — zero all dynamic factors
    adjDayOfWeek = 0;
    adjSeason = 0;
    adjLeadTime = 0;
    adjEvent = 0;
    adjDemandPickup = 0;
    adjCompSet = 0;
    adjChannel = 0;
    const contractDiscounts: Record<string, number> = {
      corporate_lnr: -0.20,
      cnr: -0.15,
      government: -0.15,
      airline_crew: -0.25,
    };
    adjSegment = round2(baseRate * (contractDiscounts[contract_type] ?? -0.20));
  }

  const rateFinal = round2(
    Math.max(
      baseRate * 0.50,
      Math.min(
        baseRate * 4.0,
        baseRate + adjDayOfWeek + adjSeason + adjEvent + adjLeadTime + adjLos + adjDemandPickup + adjCompSet + adjChannel + adjSegment
      )
    )
  );

  return NextResponse.json({
    hotel_id,
    room_type_id,
    stay_date,
    base_rate: baseRate,
    rate_final: rateFinal,
    rate_channel,
    occupancy_pct: occupancyPct,
    factors: {
      adj_day_of_week: adjDayOfWeek,
      adj_season: adjSeason,
      adj_event: adjEvent,
      adj_lead_time: adjLeadTime,
      adj_length_of_stay: adjLos,
      adj_demand_pickup: adjDemandPickup,
      adj_comp_set: adjCompSet,
      adj_channel: adjChannel,
      adj_segment: adjSegment,
    },
  });
}
