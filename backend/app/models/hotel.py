from pydantic import BaseModel
from uuid import UUID
from datetime import datetime


class RoomType(BaseModel):
    id: UUID
    hotel_id: UUID
    code: str
    name: str
    category: str
    max_occupancy: int
    bed_type: str | None
    has_view: bool
    view_type: str | None
    has_balcony: bool
    floor_level: str | None
    sq_ft: int | None
    base_rate: float
    rate_multiplier: float
    quantity: int | None


class Hotel(BaseModel):
    id: UUID
    name: str
    brand: str | None
    brand_tier: str | None
    star_rating: float | None
    tripadvisor_score: float | None
    google_score: float | None
    review_count: int
    address: str | None
    neighborhood: str | None
    latitude: float | None
    longitude: float | None
    dist_convention_ctr_miles: float | None
    dist_airport_miles: float | None
    dist_lodo_miles: float | None
    has_pool: bool
    has_spa: bool
    has_gym: bool
    has_restaurant: bool
    has_airport_shuttle: bool
    has_parking: bool
    parking_fee_nightly: float | None
    loyalty_program: str | None
    total_rooms: int | None
    is_active: bool


class HotelWithRooms(Hotel):
    room_types: list[RoomType] = []
