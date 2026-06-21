from pydantic import BaseModel
from uuid import UUID
from datetime import date


class FactorBreakdown(BaseModel):
    adj_day_of_week: float
    adj_season: float
    adj_event: float
    adj_lead_time: float
    adj_length_of_stay: float
    adj_demand_pickup: float
    adj_comp_set: float
    adj_channel: float


class PricingResult(BaseModel):
    hotel_id: UUID
    room_type_id: UUID
    stay_date: date
    base_rate: float
    rate_final: float
    rate_channel: str
    occupancy_pct: float | None
    factors: FactorBreakdown


class PricingRequest(BaseModel):
    hotel_id: UUID
    room_type_id: UUID
    stay_date: date
    lead_time_days: int = 14
    length_of_stay: int = 1
    rate_channel: str = "direct"


class RateCalendarEntry(BaseModel):
    stay_date: date
    rate_final: float
    occupancy_pct: float | None
    rooms_available: int | None
