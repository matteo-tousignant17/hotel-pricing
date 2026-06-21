CREATE TABLE room_types (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id            UUID NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,

    code                TEXT NOT NULL,
    name                TEXT NOT NULL,
    category            TEXT NOT NULL CHECK (category IN ('standard', 'deluxe', 'suite', 'penthouse')),
    max_occupancy       INTEGER DEFAULT 2,
    bed_type            TEXT CHECK (bed_type IN ('king', 'double_double', 'queen', 'twin', 'california_king')),

    has_view            BOOLEAN DEFAULT FALSE,
    view_type           TEXT CHECK (view_type IN ('mountain', 'city', 'pool', 'courtyard', 'partial')),
    has_balcony         BOOLEAN DEFAULT FALSE,
    floor_level         TEXT CHECK (floor_level IN ('low', 'mid', 'high', 'penthouse')),
    has_minibar         BOOLEAN DEFAULT FALSE,
    has_premium_bedding BOOLEAN DEFAULT FALSE,
    sq_ft               INTEGER,

    base_rate           NUMERIC(8,2) NOT NULL,
    rate_multiplier     NUMERIC(4,3) DEFAULT 1.000,
    quantity            INTEGER,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMPTZ DEFAULT now(),

    UNIQUE (hotel_id, code)
);

CREATE INDEX idx_room_types_hotel_id ON room_types (hotel_id);
CREATE INDEX idx_room_types_category ON room_types (category);
