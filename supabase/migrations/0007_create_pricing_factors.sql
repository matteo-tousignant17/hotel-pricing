-- Season definitions for Denver market
CREATE TABLE season_definitions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            TEXT NOT NULL,
    market          TEXT DEFAULT 'denver',
    month_start     INTEGER NOT NULL CHECK (month_start BETWEEN 1 AND 12),
    day_start       INTEGER NOT NULL CHECK (day_start BETWEEN 1 AND 31),
    month_end       INTEGER NOT NULL CHECK (month_end BETWEEN 1 AND 12),
    day_end         INTEGER NOT NULL CHECK (day_end BETWEEN 1 AND 31),
    demand_index    NUMERIC(4,3) NOT NULL CHECK (demand_index > 0),
    notes           TEXT
);

-- Lead time tiers: how far in advance the booking is made → rate multiplier
CREATE TABLE lead_time_tiers (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_name    TEXT NOT NULL DEFAULT 'default',
    days_min        INTEGER NOT NULL CHECK (days_min >= 0),
    days_max        INTEGER CHECK (days_max IS NULL OR days_max > days_min),
    rate_multiplier NUMERIC(4,3) NOT NULL CHECK (rate_multiplier > 0)
);

-- Algorithm weight profiles — stored in DB so UI can adjust weights live (Stage 4)
CREATE TABLE pricing_factor_weights (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_name    TEXT NOT NULL,
    is_default      BOOLEAN DEFAULT FALSE,

    -- Primary factor weights
    w_occupancy         NUMERIC(4,3) DEFAULT 0.25,
    w_lead_time         NUMERIC(4,3) DEFAULT 0.15,
    w_day_of_week       NUMERIC(4,3) DEFAULT 0.10,
    w_season            NUMERIC(4,3) DEFAULT 0.15,
    w_demand_pickup     NUMERIC(4,3) DEFAULT 0.15,
    w_comp_set          NUMERIC(4,3) DEFAULT 0.10,
    w_event             NUMERIC(4,3) DEFAULT 0.10,

    -- Secondary factor weights
    w_star_rating       NUMERIC(4,3) DEFAULT 0.05,
    w_review_score      NUMERIC(4,3) DEFAULT 0.03,
    w_channel           NUMERIC(4,3) DEFAULT 0.02,

    created_at      TIMESTAMPTZ DEFAULT now(),

    UNIQUE (profile_name)
);

-- Seed season definitions for Denver
INSERT INTO season_definitions (name, market, month_start, day_start, month_end, day_end, demand_index, notes) VALUES
    ('ski_peak',       'denver', 12, 15, 3,  10, 1.30, 'Holiday ski season through early March'),
    ('spring_break',   'denver', 3,  10, 4,  15, 1.10, 'Spring break and early spring travel'),
    ('summer_peak',    'denver', 6,  15, 8,  31, 1.25, 'Summer tourism and outdoor festivals'),
    ('fall_shoulder',  'denver', 9,   1, 10, 31, 1.05, 'Business travel resumes; leaf season'),
    ('slow',           'denver', 11,  1, 12, 14, 0.85, 'Pre-holiday slow period');

-- Seed lead time tiers
INSERT INTO lead_time_tiers (profile_name, days_min, days_max, rate_multiplier) VALUES
    ('default', 0,   1,    1.30),
    ('default', 2,   6,    1.15),
    ('default', 7,   13,   1.05),
    ('default', 14,  29,   1.00),
    ('default', 30,  59,   0.95),
    ('default', 60,  89,   0.90),
    ('default', 90,  NULL, 0.85);

-- Seed algorithm weight profiles
INSERT INTO pricing_factor_weights (profile_name, is_default, w_occupancy, w_lead_time, w_day_of_week, w_season, w_demand_pickup, w_comp_set, w_event, w_star_rating, w_review_score, w_channel) VALUES
    ('default',    TRUE,  0.25, 0.15, 0.10, 0.15, 0.15, 0.10, 0.10, 0.05, 0.03, 0.02),
    ('luxury',     FALSE, 0.15, 0.10, 0.08, 0.12, 0.10, 0.20, 0.12, 0.08, 0.08, 0.07),
    ('budget',     FALSE, 0.30, 0.20, 0.12, 0.10, 0.18, 0.05, 0.05, 0.02, 0.02, 0.06),
    ('ski_resort', FALSE, 0.20, 0.15, 0.05, 0.30, 0.15, 0.08, 0.07, 0.05, 0.03, 0.02);
