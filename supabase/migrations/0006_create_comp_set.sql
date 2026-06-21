CREATE TABLE comp_sets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id        UUID NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    comp_hotel_id   UUID NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    weight          NUMERIC(4,3) DEFAULT 1.000 CHECK (weight BETWEEN 0 AND 2),
    is_primary      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT now(),

    UNIQUE (hotel_id, comp_hotel_id),
    CHECK (hotel_id != comp_hotel_id)
);

CREATE INDEX idx_comp_sets_hotel_id ON comp_sets (hotel_id);

CREATE TABLE market_rates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id        UUID NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    stay_date       DATE NOT NULL,
    rate_channel    TEXT DEFAULT 'ota' CHECK (rate_channel IN ('ota', 'direct', 'non_refundable')),
    rate            NUMERIC(8,2) NOT NULL,
    room_category   TEXT DEFAULT 'standard' CHECK (room_category IN ('standard', 'deluxe', 'suite')),
    scraped_at      TIMESTAMPTZ DEFAULT now(),
    data_source     TEXT DEFAULT 'seed' CHECK (data_source IN ('seed', 'import', 'scrape')),

    UNIQUE (hotel_id, stay_date, rate_channel, room_category)
);

CREATE INDEX idx_market_rates_date ON market_rates (stay_date);
CREATE INDEX idx_market_rates_hotel_date ON market_rates (hotel_id, stay_date);
