CREATE TABLE events (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                    TEXT NOT NULL,
    event_type              TEXT NOT NULL CHECK (event_type IN ('sports', 'convention', 'concert', 'holiday', 'festival', 'other')),
    venue                   TEXT,
    start_date              DATE NOT NULL,
    end_date                DATE NOT NULL,

    demand_impact           TEXT NOT NULL DEFAULT 'medium' CHECK (demand_impact IN ('low', 'medium', 'high', 'citywide')),
    estimated_attendance    INTEGER,
    affected_neighborhoods  TEXT[],

    notes                   TEXT,
    source_url              TEXT,
    created_at              TIMESTAMPTZ DEFAULT now(),

    CHECK (end_date >= start_date)
);

CREATE INDEX idx_events_dates ON events (start_date, end_date);
CREATE INDEX idx_events_type ON events (event_type);
CREATE INDEX idx_events_impact ON events (demand_impact);
