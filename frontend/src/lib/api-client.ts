import type { Hotel, PricingResult, RateCalendarEntry, Event, CustomWeights } from "./types";

const BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

async function get<T>(path: string): Promise<T> {
  const res = await fetch(`${BASE}${path}`);
  if (!res.ok) throw new Error(`API ${res.status}: ${path}`);
  return res.json();
}

async function post<T>(path: string, body: unknown): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`API ${res.status}: ${path}`);
  return res.json();
}

export const api = {
  hotels: {
    list: () => get<Hotel[]>("/api/hotels"),
    get: (id: string) => get<Hotel>(`/api/hotels/${id}`),
  },
  pricing: {
    calendar: (hotelId: string, roomTypeId: string, days = 90) =>
      get<RateCalendarEntry[]>(
        `/api/pricing/${hotelId}/calendar?room_type_id=${roomTypeId}&days=${days}`
      ),
    forDate: (hotelId: string, stayDate: string, roomTypeId: string) =>
      get<PricingResult>(
        `/api/pricing/${hotelId}/${stayDate}?room_type_id=${roomTypeId}`
      ),
    calculate: (params: {
      hotel_id: string;
      room_type_id: string;
      stay_date: string;
      lead_time_days?: number;
      length_of_stay?: number;
      rate_channel?: string;
      custom_weights?: CustomWeights;
    }) => post<PricingResult>("/api/pricing/calculate", params),
  },
  events: {
    upcoming: (days = 30) => get<Event[]>(`/api/events/upcoming?days=${days}`),
    list: (start?: string, end?: string) => {
      const params = new URLSearchParams();
      if (start) params.set("start", start);
      if (end) params.set("end", end);
      const qs = params.toString();
      return get<Event[]>(`/api/events${qs ? `?${qs}` : ""}`);
    },
  },
};
