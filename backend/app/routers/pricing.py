from fastapi import APIRouter, HTTPException
from datetime import date
from uuid import UUID

from app.database import get_client
from app.models.pricing import PricingResult, PricingRequest, RateCalendarEntry
from app.services.pricing_engine import calculate_rate

router = APIRouter()


@router.get("/{hotel_id}/calendar", response_model=list[RateCalendarEntry])
def rate_calendar(hotel_id: UUID, room_type_id: UUID, days: int = 90):
    """Return pre-computed rates for the next N days (reads from rate_calendar table)."""
    from datetime import timedelta
    client = get_client()
    today = date.today()
    until = today + timedelta(days=days)

    result = (
        client.table("rate_calendar")
        .select("stay_date, rate_final, occupancy_pct, rooms_available")
        .eq("hotel_id", str(hotel_id))
        .eq("room_type_id", str(room_type_id))
        .eq("rate_channel", "direct")
        .gte("stay_date", str(today))
        .lte("stay_date", str(until))
        .order("stay_date")
        .execute()
    )
    return result.data


@router.get("/{hotel_id}/{stay_date}", response_model=PricingResult)
def rate_for_date(hotel_id: UUID, stay_date: date, room_type_id: UUID, rate_channel: str = "direct"):
    """Single-date rate with full factor breakdown from rate_calendar."""
    client = get_client()
    result = (
        client.table("rate_calendar")
        .select("*")
        .eq("hotel_id", str(hotel_id))
        .eq("room_type_id", str(room_type_id))
        .eq("stay_date", str(stay_date))
        .eq("rate_channel", rate_channel)
        .single()
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=404, detail="No rate found for this hotel/room/date combination")

    row = result.data
    return {
        **row,
        "factors": {
            "adj_day_of_week": row["adj_day_of_week"],
            "adj_season": row["adj_season"],
            "adj_event": row["adj_event"],
            "adj_lead_time": row["adj_lead_time"],
            "adj_length_of_stay": row["adj_length_of_stay"],
            "adj_demand_pickup": row["adj_demand_pickup"],
            "adj_comp_set": row["adj_comp_set"],
            "adj_channel": row["adj_channel"],
        },
    }


@router.post("/calculate", response_model=PricingResult)
def calculate_pricing(request: PricingRequest):
    """Run the pricing algorithm live for a hotel/room/date with lead time and LOS inputs."""
    result = calculate_rate(
        hotel_id=request.hotel_id,
        room_type_id=request.room_type_id,
        stay_date=request.stay_date,
        lead_time_days=request.lead_time_days,
        length_of_stay=request.length_of_stay,
        rate_channel=request.rate_channel,
    )
    if result is None:
        raise HTTPException(status_code=404, detail="Hotel or room type not found")
    return result
