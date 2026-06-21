# Hotel Pricing Tool — Denver, CO

A hotel pricing intelligence demo for the Denver, Colorado market.

## Architecture

```
frontend/    Next.js 14 (TypeScript, Tailwind, App Router)
backend/     Python FastAPI (pricing algorithm)
supabase/    PostgreSQL migrations + seed data
```

## Local Development

### 1. Database (Supabase)

Apply migrations via Supabase MCP or CLI:
```bash
supabase db push
```

Then run seed scripts from `supabase/seed/` in order.

### 2. Backend (FastAPI)

```bash
cd backend
cp .env.example .env          # fill in Supabase credentials
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API docs available at http://localhost:8000/docs

### 3. Frontend (Next.js)

```bash
cd frontend
cp .env.local.example .env.local   # fill in Supabase + API URL
npm install
npm run dev
```

Open http://localhost:3000

## Build Stages

| Stage | Status | Description |
|-------|--------|-------------|
| 1 | Done | Architecture, migrations, scaffold |
| 2 | Next | Seed ~25 Denver hotels with real data |
| 3 | Planned | UI — hotel list + detail + factor breakdown chart |
| 4 | Planned | Live pricing algorithm with adjustable weights |

## Pricing Factors

### Primary (algorithm core)
1. Occupancy rate
2. Booking window / lead time
3. Day of week
4. Season (Denver: ski peak, summer peak, shoulder, slow)
5. Room type
6. Length of stay
7. Demand pickup rate
8. Competitive set rates
9. Date-specific events (Broncos, conventions, NWSS, GABF)

### Secondary (modifiers)
1. Star rating / hotel class
2. Brand & loyalty program
3. Online reputation score
4. Physical amenities
5. Room-level amenities
6. Distribution channel
7. Guest segment
8. Cancellation policy
9. Location quality
