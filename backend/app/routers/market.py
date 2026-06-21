from fastapi import APIRouter, HTTPException
from datetime import date
from uuid import UUID

from app.database import get_client

router = APIRouter()


@router.get("/comp-rates")
def comp_rates(hotel_id: UUID, stay_date: date, room_category: str = "standard"):
    """Return comp set rates for a hotel on a given date."""
    client = get_client()

    comp_result = client.table("comp_sets").select("comp_hotel_id, weight, is_primary").eq("hotel_id", str(hotel_id)).execute()
    if not comp_result.data:
        raise HTTPException(status_code=404, detail="No comp set defined for this hotel")

    comp_ids = [c["comp_hotel_id"] for c in comp_result.data]
    rates_result = (
        client.table("market_rates")
        .select("hotel_id, rate, room_category, data_source")
        .in_("hotel_id", comp_ids)
        .eq("stay_date", str(stay_date))
        .eq("room_category", room_category)
        .execute()
    )

    comp_map = {c["comp_hotel_id"]: c for c in comp_result.data}
    for rate in rates_result.data:
        rate["weight"] = comp_map.get(rate["hotel_id"], {}).get("weight", 1.0)
        rate["is_primary"] = comp_map.get(rate["hotel_id"], {}).get("is_primary", False)

    return {
        "hotel_id": str(hotel_id),
        "stay_date": str(stay_date),
        "room_category": room_category,
        "comp_rates": rates_result.data,
        "avg_comp_rate": (
            sum(r["rate"] for r in rates_result.data) / len(rates_result.data)
            if rates_result.data else None
        ),
    }
