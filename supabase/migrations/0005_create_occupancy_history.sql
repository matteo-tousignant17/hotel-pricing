CREATE TABLE occupancy_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id        UUID NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    stay_date       DATE NOT NULL,
    year            INTEGER GENERATED ALWAYS AS (EXTRACT(YEAR FROM stay_date)::INTEGER) STORED,
    month           INTEGER GENERATED ALWAYS AS (EXTRACT(MONTH FROM stay_date)::INTEGER) STORED,
    day_of_week     INTEGER GENERATED ALWAYS AS (EXTRACT(DOW FROM stay_date)::INTEGER) STORED,
    occupancy_pct   NUMERIC(5,2) CHECK (occupancy_pct BETWEEN 0 AND 100),
    adr             NUMERIC(8,2),
    revpar          NUMERIC(8,2),
    data_source     TEXT DEFAULT 'seed' CHECK (data_source IN ('seed', 'import', 'api')),
    created_at      TIMESTAMPTZ DEFAULT now(),

    UNIQUE (hotel_id, stay_date)
);

CREATE INDEX idx_occ_history_hotel_month ON occupancy_history (hotel_id, month, day_of_week);
CREATE INDEX idx_occ_history_hotel_date ON occupancy_history (hotel_id, stay_date);
