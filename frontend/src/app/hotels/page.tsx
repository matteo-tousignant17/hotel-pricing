import type { Hotel } from "@/lib/types";
import { getServerClient } from "@/lib/supabase-server";
import { HotelList } from "@/components/hotels/HotelList";

export default async function HotelsPage() {
  let hotels: Hotel[] = [];
  let error: string | null = null;

  try {
    const supabase = getServerClient();
    const { data, error: dbError } = await supabase
      .from("hotels")
      .select("*, room_types(base_rate)")
      .eq("is_active", true)
      .order("name");

    if (dbError) throw dbError;

    hotels = ((data ?? []) as (Omit<Hotel, "room_types" | "min_rate"> & { room_types?: { base_rate: number }[] })[]).map((h) => {
      const rates = (h.room_types ?? []).map((r) => Number(r.base_rate)).filter((r) => r > 0);
      const { room_types: _, ...rest } = h;
      return { ...rest, min_rate: rates.length > 0 ? Math.min(...rates) : null } as Hotel;
    });
  } catch {
    error = "Could not load hotels — check your Supabase connection.";
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
          No hotels found — check that the database is seeded.
        </div>
      ) : (
        <HotelList hotels={hotels} />
      )}
    </div>
  );
}
