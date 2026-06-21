from fastapi import APIRouter, HTTPException
from uuid import UUID

from app.database import get_client
from app.models.hotel import Hotel, HotelWithRooms

router = APIRouter()


@router.get("", response_model=list[Hotel])
def list_hotels():
    client = get_client()
    result = client.table("hotels").select("*").eq("is_active", True).order("name").execute()
    return result.data


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
