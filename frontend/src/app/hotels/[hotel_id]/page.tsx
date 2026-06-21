import { api } from "@/lib/api-client";
import type { Hotel, PricingResult, RateCalendarEntry } from "@/lib/types";
import Link from "next/link";
import { notFound } from "next/navigation";
import { FactorBreakdownChart } from "@/components/pricing/FactorBreakdownChart";
import { RateCalendarChart } from "@/components/pricing/RateCalendarChart";
import { PricingSimulator } from "@/components/pricing/PricingSimulator";

export default async function HotelDetailPage({
  params,
}: {
  params: { hotel_id: string };
}) {
  let hotel: Hotel | undefined;
  try {
    hotel = await api.hotels.get(params.hotel_id);
  } catch {
    notFound();
  }
  if (!hotel) notFound();

  // Pick STD-K or cheapest room type for pricing data
  const stdRoom =
    hotel.room_types?.find((r) => r.code === "STD-K") ??
    hotel.room_types?.sort((a, b) => a.base_rate - b.base_rate)[0];

  const today = new Date().toISOString().slice(0, 10);

  let pricing: PricingResult | null = null;
  let calendar: RateCalendarEntry[] = [];

  if (stdRoom) {
    const [pricingResult, calendarResult] = await Promise.allSettled([
      api.pricing.forDate(hotel.id, today, stdRoom.id),
      api.pricing.calendar(hotel.id, stdRoom.id, 90),
    ]);
    if (pricingResult.status === "fulfilled") pricing = pricingResult.value;
    if (calendarResult.status === "fulfilled") calendar = calendarResult.value;
  }

  const amenities = [
    hotel.has_pool && "Pool",
    hotel.has_spa && "Spa",
    hotel.has_gym && "Gym",
    hotel.has_restaurant && "Restaurant",
    hotel.has_airport_shuttle && "Airport Shuttle",
    hotel.has_ev_charging && "EV Charging",
    hotel.has_business_center && "Business Center",
    hotel.has_parking &&
      `Parking${hotel.parking_fee_nightly ? ` ($${hotel.parking_fee_nightly}/night)` : " (free)"}`,
  ].filter(Boolean);

  return (
    <div className="space-y-8">
      <div>
        <Link href="/hotels" className="text-sm text-gray-500 hover:text-gray-700">
          ← All Hotels
        </Link>
        <h1 className="mt-2 text-2xl font-bold">{hotel.name}</h1>
        <p className="text-gray-500">
          {hotel.neighborhood} · {hotel.star_rating}★ · {hotel.brand_tier}
          {hotel.brand && ` · ${hotel.brand}`}
        </p>
      </div>

      {/* Pricing Factor Breakdown */}
      {pricing ? (
        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-1 font-semibold">Pricing Factor Breakdown</h2>
          <p className="mb-5 text-xs text-gray-500">
            {stdRoom?.name} · Direct channel · Pre-computed adjustments from rate calendar
          </p>
          <FactorBreakdownChart
            factors={pricing.factors}
            baseRate={pricing.base_rate}
            finalRate={pricing.rate_final}
            date={pricing.stay_date}
          />
        </section>
      ) : stdRoom ? (
        <section className="rounded-xl border border-amber-100 bg-amber-50 p-6">
          <h2 className="mb-1 font-semibold text-amber-800">No rate data for today</h2>
          <p className="text-sm text-amber-700">
            Rate calendar may not include today&apos;s date. Check that the seed was applied.
          </p>
        </section>
      ) : null}

      {/* 90-Day Rate Calendar */}
      {calendar.length > 0 && stdRoom && (
        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-1 font-semibold">90-Day Rate Calendar</h2>
          <p className="mb-4 text-xs text-gray-500">{stdRoom.name} · Direct channel</p>
          <RateCalendarChart entries={calendar} baseRate={stdRoom.base_rate} />
        </section>
      )}

      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 font-semibold">Property Details</h2>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between">
              <dt className="text-gray-500">Total Rooms</dt>
              <dd>{hotel.total_rooms ?? "—"}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Loyalty Program</dt>
              <dd>{hotel.loyalty_program ?? "Independent"}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">TripAdvisor</dt>
              <dd>{hotel.tripadvisor_score ?? "—"} / 5.0</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Google</dt>
              <dd>{hotel.google_score ?? "—"} / 5.0</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">Reviews</dt>
              <dd>{hotel.review_count.toLocaleString()}</dd>
            </div>
          </dl>
        </section>

        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 font-semibold">Location</h2>
          <dl className="space-y-2 text-sm">
            <div className="flex justify-between">
              <dt className="text-gray-500">Address</dt>
              <dd className="text-right">{hotel.address ?? "—"}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">To Convention Center</dt>
              <dd>
                {hotel.dist_convention_ctr_miles != null
                  ? `${hotel.dist_convention_ctr_miles} mi`
                  : "—"}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">To Airport (DIA)</dt>
              <dd>
                {hotel.dist_airport_miles != null ? `${hotel.dist_airport_miles} mi` : "—"}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-gray-500">To LoDo</dt>
              <dd>
                {hotel.dist_lodo_miles != null ? `${hotel.dist_lodo_miles} mi` : "—"}
              </dd>
            </div>
          </dl>
        </section>

        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 font-semibold">Amenities</h2>
          {amenities.length === 0 ? (
            <p className="text-sm text-gray-400">No amenities recorded</p>
          ) : (
            <div className="flex flex-wrap gap-2">
              {amenities.map((a) => (
                <span
                  key={String(a)}
                  className="rounded-full bg-gray-100 px-3 py-1 text-xs text-gray-700"
                >
                  {a}
                </span>
              ))}
            </div>
          )}
        </section>

        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 font-semibold">Room Types</h2>
          {!hotel.room_types?.length ? (
            <p className="text-sm text-gray-400">No room types seeded yet</p>
          ) : (
            <div className="space-y-3">
              {hotel.room_types.map((room) => (
                <div key={room.id} className="flex items-center justify-between text-sm">
                  <div>
                    <div className="font-medium">{room.name}</div>
                    <div className="text-xs text-gray-400">
                      {room.bed_type?.replace("_", " ")} · {room.category}
                      {room.has_view && ` · ${room.view_type} view`}
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="font-semibold">${room.base_rate}/night</div>
                    <div className="text-xs text-gray-400">{room.quantity ?? "?"} rooms</div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      </div>

      {/* Live Pricing Simulator */}
      {hotel.room_types && hotel.room_types.length > 0 && (
        <section className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-1 font-semibold">Live Pricing Simulator</h2>
          <p className="mb-6 text-xs text-gray-500">
            Adjust date, lead time, and factor weights — rate recalculates live via the pricing algorithm
          </p>
          <PricingSimulator hotelId={hotel.id} roomTypes={hotel.room_types} />
        </section>
      )}
    </div>
  );
}
