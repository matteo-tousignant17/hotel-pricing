"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import type { Hotel } from "@/lib/types";

const TIER_COLORS: Record<string, string> = {
  luxury: "bg-purple-100 text-purple-700",
  upscale: "bg-blue-100 text-blue-700",
  midscale: "bg-green-100 text-green-700",
  budget: "bg-gray-100 text-gray-600",
};

const IMPACT_COLORS: Record<string, string> = {
  high: "text-red-600 font-semibold",
  citywide: "text-purple-600 font-semibold",
  medium: "text-amber-600",
  low: "text-gray-500",
};

type SortKey = "name" | "stars" | "rate" | "rooms";
type Tier = Hotel["brand_tier"];

interface Props {
  hotels: Hotel[];
}

export function HotelList({ hotels }: Props) {
  const [tierFilter, setTierFilter] = useState<Tier | "all">("all");
  const [neighborhoodFilter, setNeighborhoodFilter] = useState<string>("all");
  const [sortKey, setSortKey] = useState<SortKey>("name");

  const neighborhoods = useMemo(() => {
    const set = new Set(hotels.map((h) => h.neighborhood).filter(Boolean) as string[]);
    return ["all", ...Array.from(set).sort()];
  }, [hotels]);

  const filtered = useMemo(() => {
    let list = hotels;
    if (tierFilter !== "all") list = list.filter((h) => h.brand_tier === tierFilter);
    if (neighborhoodFilter !== "all") list = list.filter((h) => h.neighborhood === neighborhoodFilter);
    return [...list].sort((a, b) => {
      switch (sortKey) {
        case "stars":
          return (b.star_rating ?? 0) - (a.star_rating ?? 0);
        case "rate":
          return (a.min_rate ?? Infinity) - (b.min_rate ?? Infinity);
        case "rooms":
          return (b.total_rooms ?? 0) - (a.total_rooms ?? 0);
        default:
          return a.name.localeCompare(b.name);
      }
    });
  }, [hotels, tierFilter, neighborhoodFilter, sortKey]);

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex gap-1.5">
          {(["all", "luxury", "upscale", "midscale", "budget"] as const).map((t) => (
            <button
              key={t}
              onClick={() => setTierFilter(t)}
              className={`rounded-full px-3 py-1 text-xs font-medium transition-colors ${
                tierFilter === t
                  ? t === "all"
                    ? "bg-gray-800 text-white"
                    : `${TIER_COLORS[t]} ring-2 ring-offset-1 ring-current`
                  : "bg-white border border-gray-200 text-gray-600 hover:border-gray-400"
              }`}
            >
              {t === "all" ? "All Tiers" : t.charAt(0).toUpperCase() + t.slice(1)}
            </button>
          ))}
        </div>

        <select
          value={neighborhoodFilter}
          onChange={(e) => setNeighborhoodFilter(e.target.value)}
          className="rounded-lg border border-gray-200 bg-white px-3 py-1.5 text-xs text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          {neighborhoods.map((n) => (
            <option key={n} value={n}>
              {n === "all" ? "All Neighborhoods" : n}
            </option>
          ))}
        </select>

        <div className="ml-auto flex items-center gap-1.5 text-xs text-gray-500">
          <span>Sort:</span>
          {(["name", "stars", "rate", "rooms"] as const).map((k) => (
            <button
              key={k}
              onClick={() => setSortKey(k)}
              className={`rounded px-2 py-1 transition-colors ${
                sortKey === k
                  ? "bg-gray-100 font-medium text-gray-800"
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              {k.charAt(0).toUpperCase() + k.slice(1)}
            </button>
          ))}
        </div>
      </div>

      <p className="text-sm text-gray-500">{filtered.length} properties</p>

      {/* Table */}
      <div className="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
        <table className="w-full text-sm">
          <thead className="border-b border-gray-200 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
            <tr>
              <th className="px-6 py-3">Hotel</th>
              <th className="px-6 py-3">Neighborhood</th>
              <th className="px-6 py-3">Stars</th>
              <th className="px-6 py-3">Tier</th>
              <th className="px-6 py-3">Rooms</th>
              <th className="px-6 py-3">From</th>
              <th className="px-6 py-3">Scores</th>
              <th className="px-6 py-3"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {filtered.map((hotel) => (
              <tr key={hotel.id} className="hover:bg-gray-50">
                <td className="px-6 py-4">
                  <div className="font-medium">{hotel.name}</div>
                  {hotel.brand && (
                    <div className="text-xs text-gray-400">{hotel.brand}</div>
                  )}
                </td>
                <td className="px-6 py-4 text-gray-600">{hotel.neighborhood ?? "—"}</td>
                <td className="px-6 py-4">
                  {hotel.star_rating ? (
                    <span className="font-medium text-amber-500">
                      {"★".repeat(Math.floor(hotel.star_rating))}
                      {hotel.star_rating % 1 >= 0.5 ? "½" : ""}
                    </span>
                  ) : (
                    <span className="text-gray-400">—</span>
                  )}
                </td>
                <td className="px-6 py-4">
                  {hotel.brand_tier && (
                    <span
                      className={`rounded-full px-2 py-0.5 text-xs font-medium capitalize ${TIER_COLORS[hotel.brand_tier]}`}
                    >
                      {hotel.brand_tier}
                    </span>
                  )}
                </td>
                <td className="px-6 py-4 text-gray-600">{hotel.total_rooms ?? "—"}</td>
                <td className="px-6 py-4">
                  {hotel.min_rate != null ? (
                    <span className="font-medium text-gray-800">${hotel.min_rate}/nt</span>
                  ) : (
                    <span className="text-gray-400">—</span>
                  )}
                </td>
                <td className="px-6 py-4">
                  <div className="flex gap-3 text-xs">
                    {hotel.tripadvisor_score && (
                      <span className="text-green-600">TA {hotel.tripadvisor_score}</span>
                    )}
                    {hotel.google_score && (
                      <span className="text-blue-600">G {hotel.google_score}</span>
                    )}
                  </div>
                </td>
                <td className="px-6 py-4">
                  <Link
                    href={`/hotels/${hotel.id}`}
                    className="font-medium text-blue-600 hover:text-blue-700"
                  >
                    View →
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && (
          <div className="p-12 text-center text-sm text-gray-400">
            No hotels match the selected filters.
          </div>
        )}
      </div>
    </div>
  );
}
