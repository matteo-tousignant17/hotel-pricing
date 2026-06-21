export interface RoomType {
  id: string;
  hotel_id: string;
  code: string;
  name: string;
  category: "standard" | "deluxe" | "suite" | "penthouse";
  max_occupancy: number;
  bed_type: string | null;
  has_view: boolean;
  view_type: string | null;
  has_balcony: boolean;
  floor_level: string | null;
  sq_ft: number | null;
  base_rate: number;
  rate_multiplier: number;
  quantity: number | null;
}

export interface Hotel {
  id: string;
  name: string;
  brand: string | null;
  brand_tier: "luxury" | "upscale" | "midscale" | "budget" | null;
  star_rating: number | null;
  tripadvisor_score: number | null;
  google_score: number | null;
  review_count: number;
  address: string | null;
  neighborhood: string | null;
  latitude: number | null;
  longitude: number | null;
  dist_convention_ctr_miles: number | null;
  dist_airport_miles: number | null;
  dist_lodo_miles: number | null;
  has_pool: boolean;
  has_spa: boolean;
  has_gym: boolean;
  has_restaurant: boolean;
  has_airport_shuttle: boolean;
  has_parking: boolean;
  parking_fee_nightly: number | null;
  has_ev_charging: boolean;
  has_business_center: boolean;
  loyalty_program: string | null;
  total_rooms: number | null;
  is_active: boolean;
  min_rate?: number | null;
  room_types?: RoomType[];
}

export type MarketSegment = "transient" | "group" | "contract";
export type ContractType = "corporate_lnr" | "cnr" | "airline_crew" | "government";

export interface FactorBreakdown {
  adj_day_of_week: number;
  adj_season: number;
  adj_event: number;
  adj_lead_time: number;
  adj_length_of_stay: number;
  adj_demand_pickup: number;
  adj_comp_set: number;
  adj_channel: number;
  adj_segment: number;
}

export interface PricingResult {
  hotel_id: string;
  room_type_id: string;
  stay_date: string;
  base_rate: number;
  rate_final: number;
  rate_channel: string;
  occupancy_pct: number | null;
  factors: FactorBreakdown;
}

export interface RateCalendarEntry {
  stay_date: string;
  rate_final: number;
  occupancy_pct: number | null;
  rooms_available: number | null;
}

export interface CustomWeights {
  w_day_of_week: number;
  w_season: number;
  w_lead_time: number;
  w_event: number;
  w_demand_pickup: number;
  w_comp_set: number;
}

export const DEFAULT_WEIGHTS: CustomWeights = {
  w_day_of_week: 1.0,
  w_season: 1.0,
  w_lead_time: 1.0,
  w_event: 1.0,
  w_demand_pickup: 1.0,
  w_comp_set: 1.0,
};

export interface Event {
  id: string;
  name: string;
  event_type: string;
  venue: string | null;
  start_date: string;
  end_date: string;
  demand_impact: "low" | "medium" | "high" | "citywide";
  estimated_attendance: number | null;
  affected_neighborhoods: string[] | null;
  notes: string | null;
}
