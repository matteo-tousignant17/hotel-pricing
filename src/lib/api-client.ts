import type { PricingResult, CustomWeights, MarketSegment, ContractType } from "./types";

async function post<T>(path: string, body: unknown): Promise<T> {
  const res = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`API ${res.status}: ${path}`);
  return res.json();
}

export const api = {
  pricing: {
    calculate: (params: {
      hotel_id: string;
      room_type_id: string;
      stay_date: string;
      lead_time_days?: number;
      length_of_stay?: number;
      rate_channel?: string;
      custom_weights?: CustomWeights;
      market_segment?: MarketSegment;
      contract_type?: ContractType;
      occupancy_override?: number;
    }) => post<PricingResult>("/api/pricing/calculate", params),
  },
};
