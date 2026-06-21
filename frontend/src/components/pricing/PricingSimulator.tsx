"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import { api } from "@/lib/api-client";
import { DEFAULT_WEIGHTS } from "@/lib/types";
import type { RoomType, PricingResult, CustomWeights } from "@/lib/types";
import { FactorBreakdownChart } from "./FactorBreakdownChart";

const WEIGHT_LABELS: Record<keyof CustomWeights, string> = {
  w_day_of_week: "Day of Week",
  w_season: "Season",
  w_lead_time: "Lead Time",
  w_event: "Events",
  w_demand_pickup: "Demand Pickup",
  w_comp_set: "Comp Set",
};

const WEIGHT_DESCRIPTIONS: Record<keyof CustomWeights, string> = {
  w_day_of_week: "Fri/Sat +12%, Sun +5%",
  w_season: "Summer/ski peaks",
  w_lead_time: "Last-minute premium, advance discount",
  w_event: "Broncos games, GABF, conventions",
  w_demand_pickup: "Occupancy vs. historical baseline",
  w_comp_set: "Position vs. competitor rates",
};

interface Props {
  hotelId: string;
  roomTypes: RoomType[];
}

export function PricingSimulator({ hotelId, roomTypes }: Props) {
  const defaultRoom = roomTypes.find((r) => r.code === "STD-K") ?? roomTypes[0];
  const today = new Date().toISOString().slice(0, 10);

  const [roomTypeId, setRoomTypeId] = useState(defaultRoom?.id ?? "");
  const [stayDate, setStayDate] = useState(today);
  const [leadTime, setLeadTime] = useState(14);
  const [los, setLos] = useState(1);
  const [channel, setChannel] = useState("direct");
  const [weights, setWeights] = useState<CustomWeights>({ ...DEFAULT_WEIGHTS });

  const [result, setResult] = useState<PricingResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const fetchRate = useCallback(async () => {
    if (!roomTypeId) return;
    setLoading(true);
    setError(null);
    try {
      const data = await api.pricing.calculate({
        hotel_id: hotelId,
        room_type_id: roomTypeId,
        stay_date: stayDate,
        lead_time_days: leadTime,
        length_of_stay: los,
        rate_channel: channel,
        custom_weights: weights,
      });
      setResult(data);
    } catch {
      setError("Could not calculate rate — is the API server running?");
    } finally {
      setLoading(false);
    }
  }, [hotelId, roomTypeId, stayDate, leadTime, los, channel, weights]);

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(fetchRate, 350);
    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [fetchRate]);

  const updateWeight = (key: keyof CustomWeights, value: number) =>
    setWeights((prev) => ({ ...prev, [key]: value }));

  const resetWeights = () => setWeights({ ...DEFAULT_WEIGHTS });
  const weightsModified = Object.keys(DEFAULT_WEIGHTS).some(
    (k) => weights[k as keyof CustomWeights] !== DEFAULT_WEIGHTS[k as keyof CustomWeights]
  );

  return (
    <div className="space-y-6">
      {/* Inputs */}
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        <div>
          <label className="mb-1 block text-xs font-medium text-gray-500">Stay Date</label>
          <input
            type="date"
            value={stayDate}
            min={today}
            onChange={(e) => setStayDate(e.target.value)}
            className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="mb-1 block text-xs font-medium text-gray-500">Lead Time (days)</label>
          <input
            type="number"
            value={leadTime}
            min={0}
            max={180}
            onChange={(e) => setLeadTime(Math.max(0, parseInt(e.target.value) || 0))}
            className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="mb-1 block text-xs font-medium text-gray-500">Nights</label>
          <select
            value={los}
            onChange={(e) => setLos(parseInt(e.target.value))}
            className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            {[1, 2, 3, 4, 5, 6, 7, 10, 14].map((n) => (
              <option key={n} value={n}>
                {n} {n === 1 ? "night" : "nights"}
                {n >= 7 ? " (−10%)" : n >= 3 ? " (−5%)" : ""}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="mb-1 block text-xs font-medium text-gray-500">Channel</label>
          <select
            value={channel}
            onChange={(e) => setChannel(e.target.value)}
            className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="direct">Direct</option>
            <option value="ota">OTA (+15%)</option>
            <option value="corporate">Corporate (−10%)</option>
          </select>
        </div>
      </div>

      {roomTypes.length > 1 && (
        <div>
          <label className="mb-1.5 block text-xs font-medium text-gray-500">Room Type</label>
          <div className="flex flex-wrap gap-2">
            {roomTypes.map((r) => (
              <button
                key={r.id}
                onClick={() => setRoomTypeId(r.id)}
                className={`rounded-lg border px-3 py-1.5 text-xs transition-colors ${
                  roomTypeId === r.id
                    ? "border-blue-500 bg-blue-50 font-medium text-blue-700"
                    : "border-gray-200 bg-white text-gray-600 hover:border-gray-400"
                }`}
              >
                {r.name} · ${r.base_rate}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Weight sliders */}
      <div>
        <div className="mb-3 flex items-center justify-between">
          <h3 className="text-sm font-medium text-gray-700">Factor Weights</h3>
          {weightsModified && (
            <button
              onClick={resetWeights}
              className="text-xs text-blue-600 hover:text-blue-700"
            >
              Reset to defaults
            </button>
          )}
        </div>
        <div className="grid gap-3 sm:grid-cols-2">
          {(Object.keys(DEFAULT_WEIGHTS) as (keyof CustomWeights)[]).map((key) => {
            const val = weights[key];
            const pct = Math.round(val * 100);
            return (
              <div key={key} className="space-y-1">
                <div className="flex items-center justify-between">
                  <div>
                    <span className="text-xs font-medium text-gray-700">
                      {WEIGHT_LABELS[key]}
                    </span>
                    <span className="ml-2 text-xs text-gray-400">
                      {WEIGHT_DESCRIPTIONS[key]}
                    </span>
                  </div>
                  <span
                    className={`text-xs font-semibold tabular-nums ${
                      val === 0
                        ? "text-gray-400"
                        : val > 1
                        ? "text-amber-600"
                        : val < 1
                        ? "text-blue-600"
                        : "text-gray-600"
                    }`}
                  >
                    {pct}%
                  </span>
                </div>
                <input
                  type="range"
                  min={0}
                  max={2}
                  step={0.05}
                  value={val}
                  onChange={(e) => updateWeight(key, parseFloat(e.target.value))}
                  className="h-1.5 w-full cursor-pointer appearance-none rounded-full bg-gray-200 accent-blue-600"
                />
                <div className="flex justify-between text-xs text-gray-300">
                  <span>Off</span>
                  <span>Normal</span>
                  <span>2×</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Result */}
      <div className="rounded-xl border border-gray-200 bg-gray-50 p-5">
        {loading && (
          <div className="flex items-center gap-2 text-sm text-gray-500">
            <span className="animate-pulse">●</span> Calculating…
          </div>
        )}
        {error && !loading && (
          <p className="text-sm text-red-600">{error}</p>
        )}
        {result && !loading && (
          <div className="space-y-1">
            <div className="mb-3 flex items-center gap-3 text-xs text-gray-500">
              {result.occupancy_pct != null && (
                <span>
                  Occupancy{" "}
                  <span className="font-semibold text-gray-700">
                    {Math.round(result.occupancy_pct * 100)}%
                  </span>
                </span>
              )}
              <span className="text-gray-300">·</span>
              <span>
                Algorithm output
                {weightsModified && (
                  <span className="ml-1 rounded bg-amber-100 px-1.5 py-0.5 text-amber-700">
                    custom weights
                  </span>
                )}
              </span>
            </div>
            <FactorBreakdownChart
              factors={result.factors}
              baseRate={result.base_rate}
              finalRate={result.rate_final}
              date={result.stay_date}
            />
          </div>
        )}
      </div>
    </div>
  );
}
