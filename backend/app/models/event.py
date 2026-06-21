from pydantic import BaseModel
from uuid import UUID
from datetime import date


class Event(BaseModel):
    id: UUID
    name: str
    event_type: str
    venue: str | None
    start_date: date
    end_date: date
    demand_impact: str
    estimated_attendance: int | None
    affected_neighborhoods: list[str] | None
    notes: str | None
