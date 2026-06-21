CREATE TABLE hotels (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                        TEXT NOT NULL,
    brand                       TEXT,
    brand_tier                  TEXT CHECK (brand_tier IN ('luxury', 'upscale', 'midscale', 'budget')),
    star_rating                 NUMERIC(2,1) CHECK (star_rating BETWEEN 1.0 AND 5.0),
    tripadvisor_score           NUMERIC(3,1) CHECK (tripadvisor_score BETWEEN 0 AND 5),
    google_score                NUMERIC(3,1) CHECK (google_score BETWEEN 0 AND 5),
    review_count                INTEGER DEFAULT 0,

    address                     TEXT,
    neighborhood                TEXT,
    latitude                    NUMERIC(9,6),
    longitude                   NUMERIC(9,6),
    dist_convention_ctr_miles   NUMERIC(4,2),
    dist_airport_miles          NUMERIC(4,2),
    dist_lodo_miles             NUMERIC(4,2),

    has_pool                    BOOLEAN DEFAULT FALSE,
    has_spa                     BOOLEAN DEFAULT FALSE,
    has_gym                     BOOLEAN DEFAULT FALSE,
    has_restaurant              BOOLEAN DEFAULT FALSE,
    has_airport_shuttle         BOOLEAN DEFAULT FALSE,
    has_parking                 BOOLEAN DEFAULT FALSE,
    parking_fee_nightly         NUMERIC(6,2),
    has_ev_charging             BOOLEAN DEFAULT FALSE,
    has_business_center         BOOLEAN DEFAULT FALSE,

    loyalty_program             TEXT,
    total_rooms                 INTEGER,
    is_active                   BOOLEAN DEFAULT TRUE,
    created_at                  TIMESTAMPTZ DEFAULT now(),
    updated_at                  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_hotels_neighborhood ON hotels (neighborhood);
CREATE INDEX idx_hotels_star_rating ON hotels (star_rating);
CREATE INDEX idx_hotels_brand_tier ON hotels (brand_tier);
