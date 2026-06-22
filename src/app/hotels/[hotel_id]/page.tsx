import type { Hotel, PricingResult, RateCalendarEntry } from "@/lib/types";
import { getServerClient } from "@/lib/supabase-server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { FactorBreakdownChart } from "@/components/pricing/FactorBreakdownChart";
import { RateCalendarChart } from "@/components/pricing/RateCalendarChart";
import { PricingSimulator } from "@/components/pricing/PricingSimulator";

export default async function HotelDetailPage({
  params,
}: {
  params: { hotel_id: string };
}) {
  const supabase = getServerClient();

  const { data: hotel, error } = await supabase
    .from("hotels")
    .select("*, room_types(*)")
    .eq("id", params.hotel_id)
    .single();

  if (error || !hotel) notFound();

  const typedHotel = hotel as unknown as Hotel;

  // Pick STD-K or cheapest room type for pre-computed panels
  const stdRoom =
    typedHotel.room_types?.find((r) => r.code === "STD-K") ??
    [...(typedHotel.room_types ?? [])].sort((a, b) => a.base_rate - b.base_rate)[0];

  const today = new Date().toISOString().slice(0, 10);
  const until = new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

  let pricing: PricingResult | null = null;
  let calendar: RateCalendarEntry[] = [];

  if (stdRoom) {
    const [rcRes, calRes] = await Promise.all([
      supabase
        .from("rate_calendar")
        .select("*")
        .eq("hotel_id", typedHotel.id)
        .eq("room_type_id", stdRoom.id)
        .eq("stay_date", today)
        .eq("rate_channel", "direct")
        .maybeSingle(),
      supabase
        .from("rate_calendar")
        .select("stay_date, rate_final, occupancy_pct, rooms_available")
        .eq("hotel_id", typedHotel.id)
        .eq("room_type_id", stdRoom.id)
        .eq("rate_channel", "direct")
        .gte("stay_date", today)
        .lte("stay_date", until)
        .order("stay_date"),
    ]);

    if (rcRes.data) {
      const row = rcRes.data as Record<string, number>;
      pricing = {
        hotel_id: typedHotel.id,
        room_type_id: stdRoom.id,
        stay_date: today,
        base_rate: row.base_rate,
        rate_final: row.rate_final,
        rate_floor: Math.round(row.base_rate * 0.65 * 100) / 100,
        rate_ceiling: Math.round(row.base_rate * 2.5 * 100) / 100,
        rate_channel: "direct",
        occupancy_pct: row.occupancy_pct,
        factors: {
          adj_day_of_week: row.adj_day_of_week,
          adj_season: row.adj_season,
          adj_event: row.adj_event,
          adj_lead_time: row.adj_lead_time,
          adj_length_of_stay: row.adj_length_of_stay,
          adj_demand_pickup: row.adj_demand_pickup,
          adj_comp_set: row.adj_comp_set,
          adj_channel: row.adj_channel,
          adj_segment: row.adj_segment ?? 0,
        },
      };
    }

    calendar = (calRes.data ?? []) as RateCalendarEntry[];
  }

  const amenities = [
    typedHotel.has_pool && "Pool",
    typedHotel.has_spa && "Spa",
    typedHotel.has_gym && "Gym",
    typedHotel.has_restaurant && "Restaurant",
    typedHotel.has_airport_shuttle && "Airport Shuttle",
    typedHotel.has_ev_charging && "EV Charging",
    typedHotel.has_business_center && "Business Center",
    typedHotel.has_parking &&
      `Parking${typedHotel.parking_fee_nightly ? ` ($${typedHotel.parking_fee_nightly}/night)` : " (free)"}`,
  ].filter(Boolean);

  return (
    <div className="space-y-6 sm:space-y-8">
      <div>
        <Link href="/hotels" className="text-sm text-gray-500 hover:text-gray-700">
          ← All Hotels
        </Link>
        <h1 className="mt-2 text-xl font-bold sm:text-2xl">{typedHotel.name}</h1>
        <p className="text-sm text-gray-500 sm:text-base">
          {typedHotel.neighborhood} · {typedHotel.star_rating}★ · {typedHotel.brand_tier}
          {typedHotel.brand && ` · ${typedHotel.brand}`}
        </p>
      </div>

      {/* Live Pricing Simulator — primary interactive panel */}
      {typedHotel.room_types && typedHotel.room_types.length > 0 && (
        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-1 font-semibold">Live Pricing Simulator</h2>
          <p className="mb-6 text-xs text-gray-500">
            Adjust segment, date, lead time, and factor weights — rate recalculates live
          </p>
          <PricingSimulator hotelId={typedHotel.id} roomTypes={typedHotel.room_types} />
        </section>
      )}

      {/* Pricing Factor Breakdown */}
      {pricing ? (
        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-1 font-semibold">Today&apos;s Pricing Factors</h2>
          <p className="mb-5 text-xs text-gray-500">
            {stdRoom?.name} · Direct channel · Pre-computed from rate calendar
          </p>
          <FactorBreakdownChart
            factors={pricing.factors}
            baseRate={pricing.base_rate}
            finalRate={pricing.rate_final}
            date={pricing.stay_date}
          />
        </section>
      ) : stdRoom ? (
        <section className="rounded-xl border border-amber-100 bg-amber-50 p-6">
          <h2 className="mb-1 font-semibold text-amber-800">No rate data for today</h2>
          <p className="text-sm text-amber-700">
            Rate calendar may not include today&apos;s date. Check that the seed was applied.
          </p>
        </section>
      ) : null}

      {/* 90-Day Rate Calendar */}
      {calendar.length > 0 && stdRoom && (
        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-1 font-semibold">90-Day Rate Calendar</h2>
          <p className="mb-4 text-xs text-gray-500">{stdRoom.name} · Direct channel</p>
          <RateCalendarChart entries={calendar} baseRate={stdRoom.base_rate} />
        </section>
      )}

      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 font-semibold">Property Details</h2>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between">
              <dt className="text-gray-500">Total Rooms</dt>
              <dd>{typedHotel.total_rooms ?? "—"}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Loyalty Program</dt>
              <dd>{typedHotel.loyalty_program ?? "Independent"}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">TripAdvisor</dt>
              <dd>{typedHotel.tripadvisor_score ?? "—"} / 5.0</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Google</dt>
              <dd>{typedHotel.google_score ?? "—"} / 5.0</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Reviews</dt>
              <dd>{typedHotel.review_count?.toLocaleString() ?? "—"}</dd>
            </div>
          </dl>
        </section>

        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 font-semibold">Location</h2>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between">
              <dt className="text-gray-500">Address</dt>
              <dd className="text-right">{typedHotel.address ?? "—"}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">To Convention Center</dt>
              <dd>
                {typedHotel.dist_convention_ctr_miles != null
                  ? `${typedHotel.dist_convention_ctr_miles} mi`
                  : "—"}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">To Airport (DIA)</dt>
              <dd>
                {typedHotel.dist_airport_miles != null
                  ? `${typedHotel.dist_airport_miles} mi`
                  : "—"}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">To LoDo</dt>
              <dd>
                {typedHotel.dist_lodo_miles != null ? `${typedHotel.dist_lodo_miles} mi` : "—"}
              </dd>
            </div>
          </dl>
        </section>

        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 font-semibold">Amenities</h2>
          {amenities.length === 0 ? (
            <p className="text-sm text-gray-400">No amenities recorded</p>
          ) : (
            <div className="flex flex-wrap gap-2">
              {amenities.map((a) => (
                <span
                  key={String(a)}
                  className="rounded-full bg-gray-100 px-3 py-1 text-xs text-gray-700"
                >
                  {a}
                </span>
              ))}
            </div>
          )}
        </section>

        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 font-semibold">Room Types</h2>
          {!typedHotel.room_types?.length ? (
            <p className="text-sm text-gray-400">No room types seeded yet</p>
          ) : (
            <div className="space-y-3">
              {typedHotel.room_types.map((room) => (
                <div key={room.id} className="flex items-center justify-between text-sm">
                  <div>
                    <div className="font-medium">{room.name}</div>
                    <div className="text-xs text-gray-400">
                      {room.bed_type?.replace("_", " ")} · {room.category}
                      {room.has_view && ` · ${room.view_type} view`}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="font-semibold">${room.base_rate}/night</div>
                    <div className="text-xs text-gray-400">{room.quantity ?? "?"} rooms</div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      </div>

    </div>
  );
}
