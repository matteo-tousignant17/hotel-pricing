"use client";

import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  ReferenceLine,
} from "recharts";
import type { RateCalendarEntry } from "@/lib/types";

interface Props {
  entries: RateCalendarEntry[];
  baseRate: number;
}

export function RateCalendarChart({ entries, baseRate }: Props) {
  const data = entries.map((e) => ({
    date: new Date(e.stay_date + "T00:00:00").toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
    }),
    rate: Math.round(e.rate_final),
    occ: e.occupancy_pct != null ? Math.round(e.occupancy_pct * 100) : null,
  }));

  if (data.length === 0) {
    return <p className="text-sm text-gray-400">No calendar data available.</p>;
  }

  const rates = data.map((d) => d.rate);
  const minRate = Math.min(...rates);
  const maxRate = Math.max(...rates);
  const avgRate = Math.round(rates.reduce((s, r) => s + r, 0) / rates.length);

  const tickInterval = Math.max(1, Math.floor(data.length / 7));

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-4 text-xs text-gray-500">
        <span>
          <span className="font-medium text-gray-700">${minRate}</span> low
        </span>
        <span>
          <span className="font-medium text-gray-700">${maxRate}</span> high
        </span>
        <span>
          <span className="font-medium text-gray-700">${avgRate}</span> avg
        </span>
        <span className="text-gray-400">· {data.length} days</span>
      </div>

      <div className="h-44">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ top: 4, right: 8, left: 0, bottom: 0 }}>
            <defs>
              <linearGradient id="rateGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.25} />
                <stop offset="95%" stopColor="#3b82f6" stopOpacity={0.02} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f3f4f6" />
            <XAxis
              dataKey="date"
              tick={{ fontSize: 10, fill: "#9ca3af" }}
              interval={tickInterval}
              axisLine={false}
              tickLine={false}
            />
            <YAxis
              tickFormatter={(v: number) => `$${v}`}
              tick={{ fontSize: 11, fill: "#9ca3af" }}
              domain={["auto", "auto"]}
              width={44}
              axisLine={false}
              tickLine={false}
            />
            <Tooltip
              formatter={(v: number) => [`$${v}/night`, "Rate"]}
              contentStyle={{ fontSize: 13, borderRadius: 8, border: "1px solid #e5e7eb" }}
            />
            <ReferenceLine
              y={baseRate}
              stroke="#d1d5db"
              strokeDasharray="4 4"
              label={{ value: "base", position: "right", fontSize: 10, fill: "#9ca3af" }}
            />
            <Area
              type="monotone"
              dataKey="rate"
              stroke="#3b82f6"
              strokeWidth={2}
              fill="url(#rateGrad)"
              dot={false}
              activeDot={{ r: 4 }}
              animationDuration={400}
              animationEasing="ease-out"
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
