"""
Pricing engine — Stage 4 implementation lives here.

For Stage 1/2, this returns a stub result using only the base_rate from room_types
plus simple day-of-week and season lookups. The full weighted-factor model
will replace this in Stage 4.
"""

from datetime import date
from uuid import UUID

from app.database import get_client


def calculate_rate(
    hotel_id: UUID,
    room_type_id: UUID,
    stay_date: date,
    lead_time_days: int = 14,
    length_of_stay: int = 1,
    rate_channel: str = "direct",
) -> dict | None:
    client = get_client()

    room_result = (
        client.table("room_types")
        .select("base_rate, rate_multiplier")
        .eq("id", str(room_type_id))
        .eq("hotel_id", str(hotel_id))
        .single()
        .execute()
    )
    if not room_result.data:
        return None

    base_rate = float(room_result.data["base_rate"])

    # Stub adjustments — will be replaced by full algorithm in Stage 4
    adj_day_of_week = _stub_day_of_week_adj(stay_date, base_rate)
    adj_season = _stub_season_adj(stay_date, base_rate)
    adj_lead_time = _stub_lead_time_adj(lead_time_days, base_rate)
    adj_length_of_stay = _stub_los_adj(length_of_stay, base_rate)

    rate_final = (
        base_rate
        + adj_day_of_week
        + adj_season
        + adj_lead_time
        + adj_length_of_stay
    )

    return {
        "hotel_id": hotel_id,
        "room_type_id": room_type_id,
        "stay_date": stay_date,
        "base_rate": base_rate,
        "rate_final": round(rate_final, 2),
        "rate_channel": rate_channel,
        "occupancy_pct": None,
        "factors": {
            "adj_day_of_week": adj_day_of_week,
            "adj_season": adj_season,
            "adj_event": 0.0,
            "adj_lead_time": adj_lead_time,
            "adj_length_of_stay": adj_length_of_stay,
            "adj_demand_pickup": 0.0,
            "adj_comp_set": 0.0,
            "adj_channel": 0.0,
        },
    }


def _stub_day_of_week_adj(stay_date: date, base_rate: float) -> float:
    dow = stay_date.weekday()  # 0=Mon, 4=Fri, 5=Sat
    if dow in (4, 5):  # Fri/Sat
        return round(base_rate * 0.12, 2)
    if dow == 6:  # Sun
        return round(base_rate * 0.05, 2)
    return 0.0


def _stub_season_adj(stay_date: date, base_rate: float) -> float:
    month, day = stay_date.month, stay_date.day
    if (month == 12 and day >= 15) or month in (1, 2) or (month == 3 and day <= 10):
        return round(base_rate * 0.30, 2)
    if (month == 6 and day >= 15) or month in (7, 8):
        return round(base_rate * 0.25, 2)
    if month in (3, 4):
        return round(base_rate * 0.10, 2)
    if month in (11,) or (month == 12 and day < 15):
        return round(base_rate * -0.15, 2)
    return round(base_rate * 0.05, 2)


def _stub_lead_time_adj(lead_time_days: int, base_rate: float) -> float:
    if lead_time_days <= 1:
        multiplier = 0.30
    elif lead_time_days <= 6:
        multiplier = 0.15
    elif lead_time_days <= 13:
        multiplier = 0.05
    elif lead_time_days <= 29:
        multiplier = 0.0
    elif lead_time_days <= 59:
        multiplier = -0.05
    elif lead_time_days <= 89:
        multiplier = -0.10
    else:
        multiplier = -0.15
    return round(base_rate * multiplier, 2)


def _stub_los_adj(length_of_stay: int, base_rate: float) -> float:
    if length_of_stay >= 7:
        return round(base_rate * -0.10, 2)
    if length_of_stay >= 3:
        return round(base_rate * -0.05, 2)
    return 0.0
