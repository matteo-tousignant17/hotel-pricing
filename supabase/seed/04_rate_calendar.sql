-- Stage 2 Seed: Rate Calendar, Comp Sets, and Market Rates
-- Generates 120 days of daily rates for every hotel's STD-K room type.
-- All adj_* columns are pre-computed so the UI factor breakdown is a simple SELECT.
-- Assumes hotel_ref temp table from 01_hotels.sql exists in this session.

-- ── STEP 1: COMP SETS ──────────────────────────────────────────────────────
DO $$
DECLARE
    h UUID; c UUID;
BEGIN

    -- Luxury tier
    FOR h IN SELECT id FROM hotel_ref WHERE slug IN ('four-seasons','brown-palace','kimpton-born','crawford-union') LOOP
        FOR c IN SELECT id FROM hotel_ref WHERE slug IN ('four-seasons','brown-palace','kimpton-born','crawford-union') LOOP
            IF h != c THEN
                INSERT INTO comp_sets (hotel_id, comp_hotel_id, weight, is_primary)
                VALUES (h, c, 1.000, TRUE)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END LOOP;

    -- Upscale large convention tier
    FOR h IN SELECT id FROM hotel_ref WHERE slug IN ('hyatt-regency-dtw','sheraton-downtown','le-meridien','marriott-city-center','renaissance-downtown') LOOP
        FOR c IN SELECT id FROM hotel_ref WHERE slug IN ('hyatt-regency-dtw','sheraton-downtown','le-meridien','marriott-city-center','renaissance-downtown') LOOP
            IF h != c THEN
                INSERT INTO comp_sets (hotel_id, comp_hotel_id,
                    weight,
                    is_primary)
                VALUES (h, c,
                    CASE WHEN c IN (SELECT id FROM hotel_ref WHERE slug IN ('hyatt-regency-dtw','sheraton-downtown','le-meridien')) THEN 1.200 ELSE 0.800 END,
                    c IN (SELECT id FROM hotel_ref WHERE slug IN ('hyatt-regency-dtw','sheraton-downtown','le-meridien')))
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END LOOP;

    -- Upscale mid-size (JW, Hyatt Regency DTC, Westin DIA)
    FOR h IN SELECT id FROM hotel_ref WHERE slug IN ('jw-marriott-cc','hyatt-regency-dtc','westin-dia') LOOP
        FOR c IN SELECT id FROM hotel_ref WHERE slug IN ('jw-marriott-cc','hyatt-regency-dtc','westin-dia') LOOP
            IF h != c THEN
                INSERT INTO comp_sets (hotel_id, comp_hotel_id, weight, is_primary)
                VALUES (h, c, 0.900, TRUE)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END LOOP;

    -- Midscale downtown
    FOR h IN SELECT id FROM hotel_ref WHERE slug IN ('courtyard-downtown','hampton-downtown','hilton-garden-downtown','cambria-downtown') LOOP
        FOR c IN SELECT id FROM hotel_ref WHERE slug IN ('courtyard-downtown','hampton-downtown','hilton-garden-downtown','cambria-downtown') LOOP
            IF h != c THEN
                INSERT INTO comp_sets (hotel_id, comp_hotel_id, weight, is_primary)
                VALUES (h, c, 1.000, TRUE)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END LOOP;

    -- Airport tier
    FOR h IN SELECT id FROM hotel_ref WHERE slug IN ('westin-dia','marriott-gateway','aloft-gateway','hilton-airport') LOOP
        FOR c IN SELECT id FROM hotel_ref WHERE slug IN ('westin-dia','marriott-gateway','aloft-gateway','hilton-airport') LOOP
            IF h != c THEN
                INSERT INTO comp_sets (hotel_id, comp_hotel_id,
                    weight,
                    is_primary)
                VALUES (h, c,
                    CASE WHEN c IN (SELECT id FROM hotel_ref WHERE slug IN ('marriott-gateway','hilton-airport')) THEN 1.100 ELSE 0.900 END,
                    TRUE)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END LOOP;

    -- Tech Center tier
    FOR h IN SELECT id FROM hotel_ref WHERE slug IN ('hyatt-regency-dtc','embassy-dtc','courtyard-dtc','hyatt-place-cc') LOOP
        FOR c IN SELECT id FROM hotel_ref WHERE slug IN ('hyatt-regency-dtc','embassy-dtc','courtyard-dtc','hyatt-place-cc') LOOP
            IF h != c THEN
                INSERT INTO comp_sets (hotel_id, comp_hotel_id, weight, is_primary)
                VALUES (h, c, 1.000, TRUE)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END LOOP;

    -- Budget tier
    FOR h IN SELECT id FROM hotel_ref WHERE slug IN ('la-quinta-dia','comfort-suites-dtc','extended-stay-downtown') LOOP
        FOR c IN SELECT id FROM hotel_ref WHERE slug IN ('la-quinta-dia','comfort-suites-dtc','extended-stay-downtown') LOOP
            IF h != c THEN
                INSERT INTO comp_sets (hotel_id, comp_hotel_id, weight, is_primary)
                VALUES (h, c, 1.000, FALSE)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END LOOP;

END $$;


-- ── STEP 2: RATE CALENDAR + MARKET RATES ────────────────────────────────────
-- Generates 120 days of rates for each hotel's STD-K room type.
-- adj_* values are dollar adjustments (can be negative).

DO $$
DECLARE
    h_rec     RECORD;
    rt_id     UUID;
    base      NUMERIC;
    d         DATE;
    end_date  DATE;
    dow       INTEGER;      -- 0=Sun,1=Mon,...,6=Sat
    m         INTEGER;
    dy        INTEGER;

    -- factor adjustments
    adj_dow   NUMERIC;
    adj_seas  NUMERIC;
    adj_evt   NUMERIC;
    adj_lead  NUMERIC;
    adj_los   NUMERIC;
    adj_pick  NUMERIC;
    occ_base  NUMERIC;
    occ_pct   NUMERIC;
    rooms_sold INTEGER;
    rate_final NUMERIC;

    -- occupancy base by tier
    occ_map   JSONB := '{
        "luxury":   72,
        "upscale":  75,
        "midscale": 78,
        "budget":   82
    }';

    has_event BOOLEAN;
    evt_impact TEXT;

BEGIN
    end_date := CURRENT_DATE + INTERVAL '120 days';

    FOR h_rec IN
        SELECT h.id, h.name, h.brand_tier, h.neighborhood, h.total_rooms
        FROM hotels h
        JOIN hotel_ref hr ON hr.id = h.id
    LOOP
        -- Get the STD-K room type for this hotel
        SELECT id, base_rate INTO rt_id, base
        FROM room_types
        WHERE hotel_id = h_rec.id AND code = 'STD-K'
        LIMIT 1;

        IF rt_id IS NULL THEN CONTINUE; END IF;

        occ_base := (occ_map ->> h_rec.brand_tier)::NUMERIC;

        FOR d IN SELECT generate_series(CURRENT_DATE, end_date, '1 day'::interval)::DATE LOOP
            dow  := EXTRACT(DOW FROM d)::INTEGER;   -- 0=Sun, 6=Sat
            m    := EXTRACT(MONTH FROM d)::INTEGER;
            dy   := EXTRACT(DAY FROM d)::INTEGER;

            -- ── Day of Week adjustment ────────────────────────────────────
            adj_dow := CASE
                WHEN dow IN (5, 6) THEN ROUND(base * 0.12, 2)   -- Fri/Sat +12%
                WHEN dow = 0       THEN ROUND(base * 0.05, 2)   -- Sun    +5%
                ELSE 0
            END;

            -- Adjust DOW differently for Airport/DTC (business-heavy: Mon/Thu premium instead)
            IF h_rec.neighborhood IN ('Airport', 'Tech Center') THEN
                adj_dow := CASE
                    WHEN dow IN (1, 4) THEN ROUND(base * 0.08, 2)  -- Mon/Thu +8%
                    WHEN dow IN (5, 6) THEN ROUND(base * -0.05, 2) -- Fri/Sat -5% (leisure dip)
                    ELSE 0
                END;
            END IF;

            -- ── Season adjustment ─────────────────────────────────────────
            adj_seas := CASE
                WHEN (m = 12 AND dy >= 15) OR m IN (1, 2) OR (m = 3 AND dy <= 10)
                    THEN ROUND(base * 0.28, 2)   -- ski_peak +28%
                WHEN (m = 6 AND dy >= 15) OR m IN (7, 8)
                    THEN ROUND(base * 0.22, 2)   -- summer_peak +22%
                WHEN m IN (3, 4)
                    THEN ROUND(base * 0.08, 2)   -- spring_break +8%
                WHEN m IN (9, 10)
                    THEN ROUND(base * 0.04, 2)   -- fall_shoulder +4%
                WHEN m = 11 OR (m = 12 AND dy < 15)
                    THEN ROUND(base * -0.14, 2)  -- slow -14%
                ELSE 0
            END;

            -- ── Event adjustment ──────────────────────────────────────────
            -- Check if any event overlaps this date and affects this hotel's neighborhood
            SELECT
                TRUE,
                e.demand_impact
            INTO has_event, evt_impact
            FROM events e
            WHERE d BETWEEN e.start_date AND e.end_date
              AND (
                e.affected_neighborhoods IS NULL
                OR h_rec.neighborhood = ANY(e.affected_neighborhoods)
                OR e.demand_impact = 'citywide'
              )
            ORDER BY
                CASE e.demand_impact
                    WHEN 'citywide' THEN 1
                    WHEN 'high'     THEN 2
                    WHEN 'medium'   THEN 3
                    WHEN 'low'      THEN 4
                END
            LIMIT 1;

            adj_evt := CASE evt_impact
                WHEN 'citywide' THEN ROUND(base * 0.25, 2)
                WHEN 'high'     THEN ROUND(base * 0.18, 2)
                WHEN 'medium'   THEN ROUND(base * 0.10, 2)
                WHEN 'low'      THEN ROUND(base * 0.04, 2)
                ELSE 0
            END;
            has_event := FALSE; evt_impact := NULL;  -- reset for next iteration

            -- ── Lead time: seed assumes 14-day default (=1.00 multiplier) ─
            adj_lead := 0;

            -- ── Length of stay: seed assumes 1 night (no discount) ─────────
            adj_los := 0;

            -- ── Demand pickup (simulated as ±variance around base occ) ─────
            -- Uses a pseudo-random variance keyed to hotel+date to be reproducible
            occ_pct := LEAST(98, GREATEST(20,
                occ_base
                + (CASE WHEN evt_impact IS NOT NULL THEN 15 ELSE 0 END)
                + (adj_seas / base * 25)   -- season also lifts occupancy
                + (MOD(ABS(HASHTEXT(h_rec.id::TEXT || d::TEXT)), 21) - 10)  -- ±10% random
            ));

            -- Pickup adj: if occ > threshold, raise price
            adj_pick := CASE
                WHEN occ_pct >= 90 THEN ROUND(base * 0.15, 2)
                WHEN occ_pct >= 80 THEN ROUND(base * 0.08, 2)
                WHEN occ_pct >= 70 THEN ROUND(base * 0.03, 2)
                WHEN occ_pct <= 40 THEN ROUND(base * -0.08, 2)
                ELSE 0
            END;

            rooms_sold := ROUND((occ_pct / 100.0) * h_rec.total_rooms)::INTEGER;

            rate_final := base + adj_dow + adj_seas + adj_evt + adj_lead + adj_los + adj_pick;
            rate_final := GREATEST(rate_final, base * 0.60);  -- floor at 60% of base

            INSERT INTO rate_calendar (
                hotel_id, room_type_id, stay_date, base_rate, rate_final, rate_channel,
                occupancy_pct, rooms_available, rooms_sold,
                adj_day_of_week, adj_season, adj_event, adj_lead_time,
                adj_length_of_stay, adj_demand_pickup, adj_comp_set, adj_channel,
                is_algorithm_generated
            ) VALUES (
                h_rec.id, rt_id, d, base, ROUND(rate_final, 2), 'direct',
                ROUND(occ_pct, 1),
                h_rec.total_rooms - rooms_sold,
                rooms_sold,
                adj_dow, adj_seas, adj_evt, adj_lead,
                adj_los, adj_pick, 0, 0,
                FALSE
            )
            ON CONFLICT (hotel_id, room_type_id, stay_date, rate_channel) DO NOTHING;

            -- Market rate: OTA = direct rate × 1.15 (OTA grossed up for commission)
            INSERT INTO market_rates (hotel_id, stay_date, rate_channel, rate, room_category, data_source)
            VALUES (h_rec.id, d, 'ota', ROUND(rate_final * 1.15, 2), 'standard', 'seed')
            ON CONFLICT (hotel_id, stay_date, rate_channel, room_category) DO NOTHING;

        END LOOP;  -- date loop
    END LOOP;  -- hotel loop
END $$;


-- ── STEP 3: UPDATE adj_comp_set ────────────────────────────────────────────
-- Now that all market_rates exist, compute the comp-set adjustment:
-- positive = we're priced below comp avg (room to raise); negative = above (watch it)

UPDATE rate_calendar rc
SET adj_comp_set = ROUND(
    (
        SELECT AVG(mr.rate) * cs.weight_sum / cs.count
        FROM (
            SELECT
                cs_inner.comp_hotel_id,
                cs_inner.weight,
                SUM(cs_inner.weight) OVER (PARTITION BY cs_inner.hotel_id) AS weight_sum,
                COUNT(*) OVER (PARTITION BY cs_inner.hotel_id) AS count
            FROM comp_sets cs_inner
            WHERE cs_inner.hotel_id = rc.hotel_id
        ) cs
        JOIN market_rates mr
          ON mr.hotel_id = cs.comp_hotel_id
         AND mr.stay_date = rc.stay_date
         AND mr.room_category = 'standard'
        LIMIT 1
    ) - rc.rate_final
, 2)
WHERE rc.rate_channel = 'direct';

-- Recompute rate_final to include comp_set signal (cap the adj at ±20% of base)
UPDATE rate_calendar
SET
    adj_comp_set = GREATEST(base_rate * -0.20, LEAST(base_rate * 0.20, COALESCE(adj_comp_set, 0))),
    rate_final   = ROUND(base_rate + adj_day_of_week + adj_season + adj_event
                         + adj_lead_time + adj_length_of_stay + adj_demand_pickup
                         + GREATEST(base_rate * -0.20, LEAST(base_rate * 0.20, COALESCE(adj_comp_set, 0)))
                         + adj_channel, 2)
WHERE rate_channel = 'direct';
