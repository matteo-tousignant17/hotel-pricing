import { api } from "@/lib/api-client";
import type { Hotel } from "@/lib/types";
import Link from "next/link";

function StarRating({ rating }: { rating: number | null }) {
  if (!rating) return <span className="text-gray-400">—</span>;
  return (
    <span className="font-medium text-amber-500">
      {"★".repeat(Math.floor(rating))}
      {rating % 1 >= 0.5 ? "½" : ""}
    </span>
  );
}

function TierBadge({ tier }: { tier: Hotel["brand_tier"] }) {
  const colors: Record<string, string> = {
    luxury: "bg-purple-100 text-purple-700",
    upscale: "bg-blue-100 text-blue-700",
    midscale: "bg-green-100 text-green-700",
    budget: "bg-gray-100 text-gray-600",
  };
  if (!tier) return null;
  return (
    <span className={`rounded-full px-2 py-0.5 text-xs font-medium capitalize ${colors[tier]}`}>
      {tier}
    </span>
  );
}

export default async function HotelsPage() {
  let hotels: Hotel[] = [];
  let error: string | null = null;

  try {
    hotels = await api.hotels.list();
  } catch (e) {
    error = "Could not load hotels. Make sure the API server is running.";
  }

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-2xl font-bold">Denver Hotel Market</h1>
        <p className="mt-1 text-gray-500">{hotels.length} properties</p>
      </div>

      {error && (
        <div className="mb-6 rounded-lg border border-red-200 bg-red-50 p-4 text-red-700">
          {error}
        </div>
      )}

      {hotels.length === 0 && !error && (
        <div className="rounded-lg border border-dashed border-gray-300 p-12 text-center text-gray-500">
          No hotels seeded yet — run Stage 2 seed scripts to populate the database.
        </div>
      )}

      <div className="overflow-hidden rounded-xl border border-gray-200 bg-white shadow-sm">
        <table className="w-full text-sm">
          <thead className="border-b border-gray-200 bg-gray-50 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
            <tr>
              <th className="px-6 py-3">Hotel</th>
              <th className="px-6 py-3">Neighborhood</th>
              <th className="px-6 py-3">Stars</th>
              <th className="px-6 py-3">Tier</th>
              <th className="px-6 py-3">Rooms</th>
              <th className="px-6 py-3">Scores</th>
              <th className="px-6 py-3"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {hotels.map((hotel) => (
              <tr key={hotel.id} className="hover:bg-gray-50">
                <td className="px-6 py-4">
                  <div className="font-medium">{hotel.name}</div>
                  {hotel.brand && <div className="text-xs text-gray-400">{hotel.brand}</div>}
                </td>
                <td className="px-6 py-4 text-gray-600">{hotel.neighborhood ?? "—"}</td>
                <td className="px-6 py-4">
                  <StarRating rating={hotel.star_rating} />
                </td>
                <td className="px-6 py-4">
                  <TierBadge tier={hotel.brand_tier} />
                </td>
                <td className="px-6 py-4 text-gray-600">{hotel.total_rooms ?? "—"}</td>
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
                    className="text-brand-600 hover:text-brand-700 font-medium"
                  >
                    View →
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
