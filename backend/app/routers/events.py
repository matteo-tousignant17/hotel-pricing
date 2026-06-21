from fastapi import APIRouter
from datetime import date, timedelta

from app.database import get_client
from app.models.event import Event

router = APIRouter()


@router.get("", response_model=list[Event])
def list_events(start: date | None = None, end: date | None = None):
    client = get_client()
    query = client.table("events").select("*")
    if start:
        query = query.gte("end_date", str(start))
    if end:
        query = query.lte("start_date", str(end))
    result = query.order("start_date").execute()
    return result.data


@router.get("/upcoming", response_model=list[Event])
def upcoming_events(days: int = 30):
    client = get_client()
    today = date.today()
    until = today + timedelta(days=days)
    result = (
        client.table("events")
        .select("*")
        .gte("end_date", str(today))
        .lte("start_date", str(until))
        .order("start_date")
        .execute()
    )
    return result.data
