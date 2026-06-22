"use client";

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Cell,
  ResponsiveContainer,
  ReferenceLine,
} from "recharts";
import type { FactorBreakdown } from "@/lib/types";

const LABELS: Record<keyof FactorBreakdown, string> = {
  adj_day_of_week: "Day of Week",
  adj_season: "Season",
  adj_event: "Events",
  adj_lead_time: "Lead Time",
  adj_length_of_stay: "Length of Stay",
  adj_demand_pickup: "Demand",
  adj_comp_set: "Comp Set",
  adj_channel: "Channel",
  adj_segment: "Segment",
};

// Shorter labels for narrow screens
const SHORT_LABELS: Record<keyof FactorBreakdown, string> = {
  adj_day_of_week: "DOW",
  adj_season: "Season",
  adj_event: "Events",
  adj_lead_time: "Lead",
  adj_length_of_stay: "LOS",
  adj_demand_pickup: "Demand",
  adj_comp_set: "Comp",
  adj_channel: "Channel",
  adj_segment: "Segment",
};

interface Props {
  factors: FactorBreakdown;
  baseRate: number;
  finalRate: number;
  date: string;
  rateFloor?: number;
  rateCeiling?: number;
}

export function FactorBreakdownChart({ factors, baseRate, finalRate, date, rateFloor, rateCeiling }: Props) {
  // Fixed order, all factors always present — prevents bars from jumping positions or
  // disappearing/reappearing as values change (e.g. when segment zeroes out factors)
  const data = (Object.entries(factors) as [keyof FactorBreakdown, number][])
    .map(([key, value]) => ({ key, name: LABELS[key], shortName: SHORT_LABELS[key], value }));

  const totalAdj = finalRate - baseRate;
  const formattedDate = new Date(date + "T00:00:00").toLocaleDateString("en-US", {
    weekday: "short",
    month: "short",
    day: "numeric",
    year: "numeric",
  });

  return (
    <div className="space-y-5">
      {/* Rate headline */}
      <div>
        <div className="flex flex-wrap items-baseline gap-x-2 gap-y-1">
          <span className={`text-3xl font-bold ${
            rateCeiling && finalRate > rateCeiling ? "text-red-600"
            : rateFloor && finalRate < rateFloor ? "text-blue-600"
            : ""
          }`}>${finalRate.toFixed(0)}</span>
          <span className="text-sm text-gray-500">/night</span>
          <span className="text-xs text-gray-400">{formattedDate}</span>
          {rateCeiling && finalRate > rateCeiling && (
            <span className="rounded bg-red-50 px-1.5 py-0.5 text-xs text-red-600">above guideline</span>
          )}
          {rateFloor && finalRate < rateFloor && (
            <span className="rounded bg-blue-50 px-1.5 py-0.5 text-xs text-blue-600">below guideline</span>
          )}
        </div>
        <div className="mt-1 flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-gray-500">
          <span>
            Base ${baseRate.toFixed(0)}
            {totalAdj !== 0 && (
              <span className={totalAdj > 0 ? "ml-1 text-amber-600" : "ml-1 text-green-600"}>
                {totalAdj > 0 ? " +" : " "}${totalAdj.toFixed(0)} adjustments
              </span>
            )}
          </span>
          {(rateFloor || rateCeiling) && (
            <span className="text-xs text-gray-400">
              Guideline{" "}
              <span className="font-medium text-gray-600">
                ${rateFloor?.toFixed(0) ?? "—"} min
              </span>
              {" · "}
              <span className="font-medium text-gray-600">
                ${rateCeiling?.toFixed(0) ?? "—"} max
              </span>
              <span className="ml-1 text-gray-300">(soft)</span>
            </span>
          )}
        </div>
      </div>

      {/* Bar chart — fixed layout: all factors always rendered so bars never jump positions */}
      <div className="h-64">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={data}
            layout="vertical"
            margin={{ left: 4, right: 36, top: 4, bottom: 4 }}
          >
            <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f3f4f6" />
            <XAxis
              type="number"
              tickFormatter={(v: number) => `${v >= 0 ? "+" : ""}$${v.toFixed(0)}`}
              tick={{ fontSize: 10, fill: "#9ca3af" }}
              axisLine={false}
              tickLine={false}
            />
            <YAxis
              type="category"
              dataKey="shortName"
              width={52}
              tick={{ fontSize: 11, fill: "#374151" }}
              axisLine={false}
              tickLine={false}
            />
            <Tooltip
              formatter={(value: number) => [
                `${value >= 0 ? "+" : ""}$${Math.abs(value).toFixed(2)}`,
                "Adjustment",
              ]}
              labelFormatter={(_, payload) => payload?.[0]?.payload?.name ?? ""}
              contentStyle={{ fontSize: 13, borderRadius: 8, border: "1px solid #e5e7eb" }}
            />
            <ReferenceLine x={0} stroke="#d1d5db" />
            <Bar dataKey="value" radius={[0, 4, 4, 0]} isAnimationActive={false}>
              {data.map((entry, i) => (
                <Cell
                  key={i}
                  fill={entry.value >= 0 ? "#f59e0b" : "#10b981"}
                  fillOpacity={entry.value === 0 ? 0.15 : 0.85}
                />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Stat grid */}
      <div className="grid grid-cols-4 gap-1.5 sm:grid-cols-4 md:gap-2">
        {(Object.entries(factors) as [keyof FactorBreakdown, number][]).map(([key, value]) => (
          <div
            key={key}
            className={`rounded-lg border px-2 py-2 text-center text-xs ${
              value > 0
                ? "border-amber-200 bg-amber-50 text-amber-800"
                : value < 0
                ? "border-green-200 bg-green-50 text-green-800"
                : "border-gray-100 bg-gray-50 text-gray-400"
            }`}
          >
            <div className="font-semibold">
              {value === 0 ? "—" : `${value > 0 ? "+" : ""}$${value.toFixed(0)}`}
            </div>
            <div className="mt-0.5 leading-tight">{SHORT_LABELS[key]}</div>
          </div>
        ))}
      </div>
    </div>
  );
}
