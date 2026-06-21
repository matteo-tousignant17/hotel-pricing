import { api } from "@/lib/api-client";
import type { Hotel } from "@/lib/types";
import { HotelList } from "@/components/hotels/HotelList";

export default async function HotelsPage() {
  let hotels: Hotel[] = [];
  let error: string | null = null;

  try {
    hotels = await api.hotels.list();
  } catch {
    error = "Could not load hotels. Make sure the API server is running.";
  }

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-2xl font-bold">Denver Hotel Market</h1>
        <p className="mt-1 text-sm text-gray-500">
          25 properties across Downtown, Airport, Cherry Creek, and Tech Center
        </p>
      </div>

      {error && (
        <div className="mb-6 rounded-lg border border-red-200 bg-red-50 p-4 text-red-700">
          {error}
        </div>
      )}

      {hotels.length === 0 && !error ? (
        <div className="rounded-lg border border-dashed border-gray-300 p-12 text-center text-gray-500">
          No hotels found — check that the database is seeded and the API is running.
        </div>
      ) : (
        <HotelList hotels={hotels} />
      )}
    </div>
  );
}
