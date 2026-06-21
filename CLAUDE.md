# Hotel Pricing — Denver

Demo tool for a professional hotel pricing consultant showing Denver market hotels, the factors driving their nightly rates, and a live pricing algorithm with adjustable weights.

## What It Does

- **Hotel list**: 25 real Denver hotels with tier/neighborhood filters, min rates, review scores
- **Hotel detail**: today's pricing factor breakdown (bar chart), 90-day rate calendar (area chart), live pricing simulator
- **Events calendar**: Denver event calendar grouped by month with demand impact badges
- **Live pricing simulator**: adjust date, lead time, length of stay, channel, and factor weight sliders — rate recalculates live via the pricing algorithm

---

## Tech Stack

- **Frontend**: Next.js 14 App Router, TypeScript, Tailwind CSS
- **Database**: Supabase (PostgreSQL) — project `ppxigsoahqcewitexuhr`
- **Charts**: recharts (FactorBreakdownChart, RateCalendarChart)
- **Deployment**: Vercel (frontend only — no separate backend needed)

No Python/FastAPI backend. All data access happens in Next.js server components via direct Supabase queries. The pricing algorithm runs as a Next.js API route.

---

## Project Structure

```
hotel-pricing/
├── vercel.json                          # Points Vercel at frontend/ subdirectory
├── frontend/
│   ├── src/
│   │   ├── app/
│   │   │   ├── layout.tsx               # Nav (Hotels + Events links), global styles
│   │   │   ├── page.tsx                 # Redirects to /hotels
│   │   │   ├── hotels/page.tsx          # Hotel list (server component, Supabase)
│   │   │   ├── hotels/[hotel_id]/page.tsx  # Hotel detail (server component)
│   │   │   ├── events/page.tsx          # Event calendar (server component)
│   │   │   └── api/pricing/calculate/route.ts  # POST — pricing algorithm
│   │   ├── components/
│   │   │   ├── hotels/HotelList.tsx     # Filter bar + mobile cards + desktop table
│   │   │   └── pricing/
│   │   │       ├── FactorBreakdownChart.tsx  # Horizontal bar chart of adj_* factors
│   │   │       ├── RateCalendarChart.tsx     # 90-day area chart
│   │   │       └── PricingSimulator.tsx      # Client component — sliders + live calc
│   │   └── lib/
│   │       ├── types.ts                 # All TypeScript interfaces
│   │       ├── supabase-server.ts       # Server-side Supabase client (uses service key)
│   │       ├── supabase.ts              # Browser-side Supabase client (unused currently)
│   │       └── api-client.ts            # Thin fetch wrapper for /api/pricing/calculate
├── supabase/
│   ├── migrations/                      # 7 SQL migration files (all applied)
│   └── seed/                            # 4 SQL seed files
│       ├── 01_hotels.sql                # 25 Denver hotels
│       ├── 02_room_types.sql            # 2–4 room types per hotel
│       ├── 03_events_2026.sql           # Denver event calendar
│       └── 04_rate_calendar.sql         # 120 days of rates + comp sets + market rates
└── backend/                             # Python FastAPI — no longer used, kept for reference
```

---

## Environment Variables

### Local development — create `frontend/.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=https://ppxigsoahqcewitexuhr.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBweGlnc29haHFjZXdpdGV4dWhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwMjU3NjgsImV4cCI6MjA5NzYwMTc2OH0.9nZyAP15aZ9kjJZi28OqN8zbPz7HOpaB4FTDEhxRGG4
# Optional — bypasses RLS server-side (get from Supabase Dashboard → Settings → API)
# SUPABASE_SERVICE_KEY=your-service-role-key-here
```

### Vercel — set in dashboard (Settings → Environment Variables):
Same two variables above. Must be set for production to work — without them the app builds but can't reach Supabase.

---

## Local Development

```bash
cd frontend
npm install
npm run dev      # http://localhost:3000
```

---

## Deployment

The app deploys to Vercel automatically on push to `main`. `vercel.json` at the repo root tells Vercel to build from the `frontend/` subdirectory.

**Important**: Vercel must have `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` set in project settings or the app will error.

---

## Database Schema

### Supabase project: `ppxigsoahqcewitexuhr`

#### Core tables

**`hotels`** — 25 Denver properties
- `brand_tier`: `luxury | upscale | midscale | budget`
- `neighborhood`: `LoDo | Downtown | Airport | Cherry Creek | Tech Center`
- `dist_convention_ctr_miles`, `dist_airport_miles`, `dist_lodo_miles`
- Amenity booleans: `has_pool`, `has_spa`, `has_gym`, `has_restaurant`, `has_airport_shuttle`, `has_ev_charging`, `has_business_center`, `has_parking`

**`room_types`** — 2–4 per hotel
- `code`: `STD-K | STD-DD | DLX-K | STE-1BR | PH`
- `category`: `standard | deluxe | suite | penthouse`
- `base_rate`, `rate_multiplier` (relative to hotel avg)

**`rate_calendar`** — central transactional table
- `UNIQUE(hotel_id, room_type_id, stay_date, rate_channel)`
- Pre-computed factor columns: `adj_day_of_week`, `adj_season`, `adj_event`, `adj_lead_time`, `adj_length_of_stay`, `adj_demand_pickup`, `adj_comp_set`, `adj_channel`
- These `adj_*` columns power the factor breakdown chart — no join-time computation needed

**`events`** — Denver event calendar
- `demand_impact`: `low | medium | high | citywide`
- `affected_neighborhoods TEXT[]` — airport hotels get $0 for Broncos games since `Airport` isn't in `['LoDo','Downtown']`

**`season_definitions`** — named seasons with date ranges and demand_index
**`lead_time_tiers`** — booking window buckets mapped to rate_multiplier
**`comp_sets`** — hotel_id + comp_hotel_id pairs
**`market_rates`** — competitor OTA rates (rate = base × 1.15)
**`occupancy_history`** — historical occupancy/ADR/RevPAR

---

## Pricing Algorithm

Lives in `frontend/src/app/api/pricing/calculate/route.ts`.

**POST `/api/pricing/calculate`** — body:
```json
{
  "hotel_id": "uuid",
  "room_type_id": "uuid",
  "stay_date": "2026-07-04",
  "lead_time_days": 14,
  "length_of_stay": 1,
  "rate_channel": "direct",
  "custom_weights": { "w_day_of_week": 1.0, "w_season": 1.5, ... }
}
```

**Factor calculations** (all in `$` relative to `base_rate`):

| Factor | Logic |
|--------|-------|
| Day of week | Fri/Sat = +12%, Sun = +5%, other = 0% |
| Season | Matches `season_definitions` by month/day; ski_peak wraps year (Dec 15–Mar 10) |
| Lead time | Matches `lead_time_tiers` by `lead_time_days` |
| Length of stay | 7+ nights = −10%, 3–6 nights = −5% |
| Events | Max impact of matching events; `affected_neighborhoods` or `citywide`; impact map: citywide=30%, high=15%, medium=8%, low=3% |
| Demand pickup | Occupancy delta vs. tier baseline (luxury 72%, upscale 73%, midscale 78%, budget 82%); steps: ≥+18%→+12%, ≥+10%→+7%, ≥+4%→+3%, ±4%→0, ≥−10%→−3%, else→−6% |
| Comp set | Avg competitor direct rate (OTA ÷ 1.15); nudge = clamp(±20%) × 35% of gap |
| Channel | OTA = +15%, corporate = −10%, direct = 0% |

**Rate floor**: `base_rate × 0.50` | **ceiling**: `base_rate × 4.0`

Custom weights (0–2, default 1.0) multiply each factor: `adj_X = base_rate × weight_X × raw_effect_X`

**Year-wrap season matching** uses `month * 100 + day` integer encoding:
```typescript
if (start <= end) return check >= start && check <= end;
return check >= start || check <= end; // wraps (e.g. 1215 → 0310)
```

---

## Key Design Decisions

- **Pre-computed `adj_*` columns** in `rate_calendar`: the factor breakdown panel is a simple SELECT, no computation at read time. Seeds store these values; the live simulator recomputes them via the API route.
- **No FastAPI backend**: eliminated to allow free Vercel deployment. Server components hit Supabase directly; only the simulator needs an API route.
- **`vercel.json` at repo root**: fixes Vercel detecting the wrong build root (repo root instead of `frontend/`).
- **`getServerClient()`** uses `SUPABASE_SERVICE_KEY ?? NEXT_PUBLIC_SUPABASE_ANON_KEY` — service key bypasses RLS server-side; anon key works if RLS allows reads.
- **Mobile responsive**: `HotelList` uses card layout on mobile (`sm:hidden`) and table on desktop (`hidden sm:block`); `FactorBreakdownChart` uses 52px YAxis with short labels.

---

## Denver Market: 25 Hotels

| Neighborhood | Tier | Hotels |
|---|---|---|
| LoDo | luxury | Four Seasons, Brown Palace, Kimpton Born, Crawford at Union Station |
| Downtown | upscale | Hyatt Regency (1100 rooms), Sheraton (1231 rooms), Le Méridien, Marriott City Center, Renaissance |
| Downtown | midscale | Courtyard Downtown, Hampton Inn, Hilton Garden Inn, Cambria |
| Airport | upscale/midscale | Westin DIA, Marriott Gateway, Aloft Gateway, Hilton Airport |
| Cherry Creek | upscale/midscale | JW Marriott, Hyatt Place |
| Tech Center | upscale/midscale | Hyatt Regency DTC, Embassy Suites DTC, Courtyard DTC |
| Various | budget | La Quinta DIA, Comfort Suites DTC, Extended Stay America Downtown |
