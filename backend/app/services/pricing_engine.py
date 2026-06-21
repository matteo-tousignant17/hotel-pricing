"""
Pricing engine — Stage 4: full weighted-factor algorithm.

Each factor produces a raw dollar adjustment at weight=1.0.
Custom weights scale those adjustments (0.0 = ignore, 1.0 = default, 2.0 = 2× emphasis).
"""

from datetime import date, timedelta
from typing import Any

from app.database import get_client


TIER_BASELINE_OCC: dict[str, float] = {
    "luxury": 0.72,
    "upscale": 0.73,
    "midscale": 0.78,
    "budget": 0.82,
}

DEFAULT_WEIGHTS: dict[str, float] = {
    "w_day_of_week": 1.0,
    "w_season": 1.0,
    "w_lead_time": 1.0,
    "w_event": 1.0,
    "w_demand_pickup": 1.0,
    "w_comp_set": 1.0,
}


def calculate_rate(
    hotel_id: Any,
    room_type_id: Any,
    stay_date: date,
    lead_time_days: int = 14,
    length_of_stay: int = 1,
    rate_channel: str = "direct",
    custom_weights: dict[str, float] | None = None,
) -> dict | None:
    client = get_client()

    hotel_result = (
        client.table("hotels")
        .select("id, brand_tier, neighborhood, star_rating, google_score, tripadvisor_score")
        .eq("id", str(hotel_id))
        .single()
        .execute()
    )
    room_result = (
        client.table("room_types")
        .select("base_rate, rate_multiplier, name")
        .eq("id", str(room_type_id))
        .eq("hotel_id", str(hotel_id))
        .single()
        .execute()
    )
    if not hotel_result.data or not room_result.data:
        return None

    hotel = hotel_result.data
    base_rate = float(room_result.data["base_rate"])
    weights = {**DEFAULT_WEIGHTS, **(custom_weights or {})}

    # --- Day of week ---
    dow = stay_date.weekday()  # 0=Mon, 4=Fri, 5=Sat, 6=Sun
    if dow in (4, 5):
        raw_dow = 0.12
    elif dow == 6:
        raw_dow = 0.05
    else:
        raw_dow = 0.0
    adj_day_of_week = round(base_rate * weights["w_day_of_week"] * raw_dow, 2)

    # --- Season ---
    season = _get_season(client, stay_date)
    raw_season = (float(season["demand_index"]) - 1.0) if season else 0.05
    adj_season = round(base_rate * weights["w_season"] * raw_season, 2)

    # --- Lead time ---
    lt_tier = _get_lead_time_tier(client, lead_time_days)
    raw_lt = (float(lt_tier["rate_multiplier"]) - 1.0) if lt_tier else 0.0
    adj_lead_time = round(base_rate * weights["w_lead_time"] * raw_lt, 2)

    # --- Length of stay (fixed discount — not user-weighted) ---
    if length_of_stay >= 7:
        adj_length_of_stay = round(base_rate * -0.10, 2)
    elif length_of_stay >= 3:
        adj_length_of_stay = round(base_rate * -0.05, 2)
    else:
        adj_length_of_stay = 0.0

    # --- Events ---
    matching_events = _get_events_for_date(client, stay_date, hotel.get("neighborhood"))
    if matching_events:
        raw_event = max(_event_effect(e["demand_impact"]) for e in matching_events)
    else:
        raw_event = 0.0
    adj_event = round(base_rate * weights["w_event"] * raw_event, 2)

    # --- Occupancy / demand pickup ---
    occ_result = (
        client.table("rate_calendar")
        .select("occupancy_pct")
        .eq("hotel_id", str(hotel_id))
        .eq("stay_date", str(stay_date))
        .eq("rate_channel", "direct")
        .limit(1)
        .execute()
    )
    if occ_result.data and occ_result.data[0].get("occupancy_pct") is not None:
        occupancy_pct = float(occ_result.data[0]["occupancy_pct"])
    else:
        occupancy_pct = TIER_BASELINE_OCC.get(hotel.get("brand_tier"), 0.73)

    baseline_occ = TIER_BASELINE_OCC.get(hotel.get("brand_tier"), 0.73)
    occ_delta = occupancy_pct - baseline_occ
    if occ_delta >= 0.18:
        raw_demand = 0.12
    elif occ_delta >= 0.10:
        raw_demand = 0.07
    elif occ_delta >= 0.04:
        raw_demand = 0.03
    elif occ_delta >= -0.04:
        raw_demand = 0.0
    elif occ_delta >= -0.10:
        raw_demand = -0.03
    else:
        raw_demand = -0.06
    adj_demand_pickup = round(base_rate * weights["w_demand_pickup"] * raw_demand, 2)

    # --- Comp set ---
    comp_rates = _get_comp_rates(client, str(hotel_id), stay_date)
    if comp_rates:
        avg_comp_ota = sum(comp_rates) / len(comp_rates)
        avg_comp_direct = avg_comp_ota / 1.15
        raw_comp = (avg_comp_direct - base_rate) / base_rate
        raw_comp = max(-0.20, min(0.20, raw_comp)) * 0.35
        adj_comp_set = round(base_rate * weights["w_comp_set"] * raw_comp, 2)
    else:
        adj_comp_set = 0.0

    # --- Channel ---
    if rate_channel == "ota":
        adj_channel = round(base_rate * 0.15, 2)
    elif rate_channel == "corporate":
        adj_channel = round(base_rate * -0.10, 2)
    else:
        adj_channel = 0.0

    rate_final = (
        base_rate
        + adj_day_of_week
        + adj_season
        + adj_event
        + adj_lead_time
        + adj_length_of_stay
        + adj_demand_pickup
        + adj_comp_set
        + adj_channel
    )
    rate_final = max(base_rate * 0.50, min(base_rate * 4.0, rate_final))

    return {
        "hotel_id": hotel_id,
        "room_type_id": room_type_id,
        "stay_date": stay_date,
        "base_rate": base_rate,
        "rate_final": round(rate_final, 2),
        "rate_channel": rate_channel,
        "occupancy_pct": occupancy_pct,
        "factors": {
            "adj_day_of_week": adj_day_of_week,
            "adj_season": adj_season,
            "adj_event": adj_event,
            "adj_lead_time": adj_lead_time,
            "adj_length_of_stay": adj_length_of_stay,
            "adj_demand_pickup": adj_demand_pickup,
            "adj_comp_set": adj_comp_set,
            "adj_channel": adj_channel,
        },
    }


def _get_season(client: Any, stay_date: date) -> dict | None:
    seasons = client.table("season_definitions").select("*").execute().data or []
    month, day = stay_date.month, stay_date.day
    for season in seasons:
        if _date_in_range(month, day, season["month_start"], season["day_start"],
                          season["month_end"], season["day_end"]):
            return season
    return None


def _date_in_range(month: int, day: int,
                   s_month: int, s_day: int,
                   e_month: int, e_day: int) -> bool:
    check = month * 100 + day
    start = s_month * 100 + s_day
    end = e_month * 100 + e_day
    if start <= end:
        return start <= check <= end
    # Wraps year (e.g., Dec 15 – Mar 10)
    return check >= start or check <= end


def _get_lead_time_tier(client: Any, lead_time_days: int) -> dict | None:
    tiers = (
        client.table("lead_time_tiers")
        .select("*")
        .order("days_min")
        .execute()
        .data or []
    )
    for tier in tiers:
        max_days = tier.get("days_max")
        if tier["days_min"] <= lead_time_days and (max_days is None or lead_time_days <= max_days):
            return tier
    return None


def _get_events_for_date(client: Any, stay_date: date, neighborhood: str | None) -> list[dict]:
    result = (
        client.table("events")
        .select("demand_impact, affected_neighborhoods")
        .lte("start_date", str(stay_date))
        .gte("end_date", str(stay_date))
        .execute()
    )
    matching = []
    for event in (result.data or []):
        affected = event.get("affected_neighborhoods") or []
        if (
            event["demand_impact"] == "citywide"
            or not affected
            or (neighborhood and neighborhood in affected)
        ):
            matching.append(event)
    return matching


def _event_effect(demand_impact: str) -> float:
    return {"citywide": 0.30, "high": 0.15, "medium": 0.08, "low": 0.03}.get(demand_impact, 0.0)


def _get_comp_rates(client: Any, hotel_id: str, stay_date: date) -> list[float]:
    comp_result = (
        client.table("comp_sets")
        .select("comp_hotel_id")
        .eq("hotel_id", hotel_id)
        .execute()
    )
    if not comp_result.data:
        return []
    comp_ids = [r["comp_hotel_id"] for r in comp_result.data]
    rates_result = (
        client.table("market_rates")
        .select("rate")
        .in_("hotel_id", comp_ids)
        .eq("stay_date", str(stay_date))
        .eq("rate_channel", "ota")
        .execute()
    )
    return [float(r["rate"]) for r in (rates_result.data or []) if r.get("rate")]
