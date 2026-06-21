CREATE TABLE rate_calendar (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hotel_id                UUID NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    room_type_id            UUID NOT NULL REFERENCES room_types(id) ON DELETE CASCADE,
    stay_date               DATE NOT NULL,

    base_rate               NUMERIC(8,2) NOT NULL,
    rate_final              NUMERIC(8,2) NOT NULL,
    rate_channel            TEXT NOT NULL DEFAULT 'direct' CHECK (rate_channel IN ('direct', 'expedia', 'booking', 'non_refundable', 'loyalty')),

    occupancy_pct           NUMERIC(5,2) CHECK (occupancy_pct BETWEEN 0 AND 100),
    rooms_available         INTEGER,
    rooms_sold              INTEGER,

    -- Pre-computed factor adjustments (dollar amounts, signed)
    -- These power the UI factor breakdown panel without join-time computation
    adj_day_of_week         NUMERIC(8,2) DEFAULT 0,
    adj_season              NUMERIC(8,2) DEFAULT 0,
    adj_event               NUMERIC(8,2) DEFAULT 0,
    adj_lead_time           NUMERIC(8,2) DEFAULT 0,
    adj_length_of_stay      NUMERIC(8,2) DEFAULT 0,
    adj_demand_pickup       NUMERIC(8,2) DEFAULT 0,
    adj_comp_set            NUMERIC(8,2) DEFAULT 0,
    adj_channel             NUMERIC(8,2) DEFAULT 0,

    is_algorithm_generated  BOOLEAN DEFAULT FALSE,
    algorithm_version       TEXT,
    created_at              TIMESTAMPTZ DEFAULT now(),
    updated_at              TIMESTAMPTZ DEFAULT now(),

    UNIQUE (hotel_id, room_type_id, stay_date, rate_channel)
);

CREATE INDEX idx_rate_calendar_hotel_date ON rate_calendar (hotel_id, stay_date);
CREATE INDEX idx_rate_calendar_date ON rate_calendar (stay_date);
CREATE INDEX idx_rate_calendar_room_date ON rate_calendar (room_type_id, stay_date);
