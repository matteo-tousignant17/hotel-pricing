from fastapi import APIRouter, HTTPException
from uuid import UUID

from app.database import get_client
from app.models.hotel import Hotel, HotelWithRooms

router = APIRouter()


@router.get("", response_model=list[Hotel])
def list_hotels():
    client = get_client()
    result = (
        client.table("hotels")
        .select("*, room_types(base_rate)")
        .eq("is_active", True)
        .order("name")
        .execute()
    )
    hotels = []
    for h in result.data:
        rates = [r["base_rate"] for r in (h.pop("room_types", None) or []) if r.get("base_rate")]
        h["min_rate"] = min(rates) if rates else None
        hotels.append(h)
    return hotels


@router.get("/{hotel_id}", response_model=HotelWithRooms)
def get_hotel(hotel_id: UUID):
    client = get_client()
    hotel_result = client.table("hotels").select("*").eq("id", str(hotel_id)).single().execute()
    if not hotel_result.data:
        raise HTTPException(status_code=404, detail="Hotel not found")

    rooms_result = client.table("room_types").select("*").eq("hotel_id", str(hotel_id)).eq("is_active", True).execute()
    hotel = hotel_result.data
    hotel["room_types"] = rooms_result.data
    return hotel
