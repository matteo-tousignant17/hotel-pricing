-- Stage 2 Seed: Room Types
-- Assumes hotel_ref temp table exists from 01_hotels.sql (run in same session)
-- Each hotel gets 2–4 room types. STD-K is the anchor; others use rate_multiplier.

DO $$
DECLARE
    h_id UUID;
    base NUMERIC;
BEGIN

    -- ── FOUR SEASONS (luxury, $450 base) ───────────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'four-seasons';
    base := 450.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Deluxe King',              'standard',  2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  480, base * 1.00, 1.000, 60),
        (h_id, 'STD-DD',  'Deluxe Double',             'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'mid',       TRUE,  TRUE,  480, base * 0.95, 0.950, 40),
        (h_id, 'STE-1BR', 'One-Bedroom Suite',         'suite',     2, 'king',          TRUE,  'mountain', FALSE, 'high',      TRUE,  TRUE,  980, base * 2.10, 2.100, 25),
        (h_id, 'PH',      'Penthouse Suite',           'penthouse', 4, 'king',          TRUE,  'city',     TRUE,  'penthouse', TRUE,  TRUE, 2200, base * 3.80, 3.800, 4);

    -- ── BROWN PALACE (luxury, $400 base) ───────────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'brown-palace';
    base := 400.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Classic King Room',         'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       TRUE,  TRUE,  350, base * 1.00, 1.000, 80),
        (h_id, 'DLX-K',   'Atrium King',               'deluxe',    2, 'king',          TRUE,  'partial',  FALSE, 'high',      TRUE,  TRUE,  420, base * 1.20, 1.200, 60),
        (h_id, 'STE-1BR', 'Palace Suite',              'suite',     2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  850, base * 2.00, 2.000, 20),
        (h_id, 'PH',      'Presidential Suite',        'penthouse', 4, 'king',          TRUE,  'city',     FALSE, 'penthouse', TRUE,  TRUE, 1800, base * 3.50, 3.500, 3);

    -- ── KIMPTON BORN (upscale, $250 base) ──────────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'kimpton-born';
    base := 250.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Born King',                 'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, TRUE,  340, base * 1.00, 1.000, 90),
        (h_id, 'DLX-K',   'Union Station View King',   'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, TRUE,  380, base * 1.18, 1.180, 55),
        (h_id, 'STE-1BR', 'Born Suite',                'suite',     2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  720, base * 1.90, 1.900, 15);

    -- ── CRAWFORD UNION STATION (upscale, $260 base) ─────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'crawford-union';
    base := 260.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Queen Depot Room',          'standard',  2, 'queen',         FALSE, NULL,       FALSE, 'low',       FALSE, TRUE,  280, base * 1.00, 1.000, 55),
        (h_id, 'DLX-K',   'King Mezzanine',            'deluxe',    2, 'king',          TRUE,  'partial',  FALSE, 'mid',       FALSE, TRUE,  320, base * 1.15, 1.150, 35),
        (h_id, 'STE-1BR', 'Architect Suite',           'suite',     2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  680, base * 1.85, 1.850, 12);

    -- ── HYATT REGENCY DOWNTOWN (upscale large, $185 base) ──────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'hyatt-regency-dtw';
    base := 185.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Standard King',             'standard',  2, 'king',          FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 380, base * 1.00, 1.000, 400),
        (h_id, 'STD-DD',  'Standard Double Double',    'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 380, base * 0.95, 0.950, 280),
        (h_id, 'DLX-K',   'Regency Club King',         'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, TRUE,  420, base * 1.30, 1.300, 200),
        (h_id, 'STE-1BR', 'Regency Suite',             'suite',     2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  840, base * 2.00, 2.000, 50);

    -- ── SHERATON DOWNTOWN (upscale large, $180 base) ────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'sheraton-downtown';
    base := 180.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Traditional King',          'standard',  2, 'king',          FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 375, base * 1.00, 1.000, 450),
        (h_id, 'STD-DD',  'Traditional Double Double', 'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 375, base * 0.95, 0.950, 350),
        (h_id, 'DLX-K',   'Club King',                 'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, FALSE, 400, base * 1.22, 1.220, 220),
        (h_id, 'STE-1BR', 'Junior Suite',              'suite',     2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, TRUE,  750, base * 1.85, 1.850, 55);

    -- ── LE MÉRIDIEN (upscale, $230 base) ───────────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'le-meridien';
    base := 230.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Superior King',             'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       TRUE,  TRUE,  350, base * 1.00, 1.000, 120),
        (h_id, 'DLX-K',   'Deluxe King City View',     'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  390, base * 1.20, 1.200, 80),
        (h_id, 'STE-1BR', 'Luminary Suite',            'suite',     2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  800, base * 1.95, 1.950, 20);

    -- ── MARRIOTT CITY CENTER (upscale, $210 base) ───────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'marriott-city-center';
    base := 210.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'City Center King',          'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 380, base * 1.00, 1.000, 250),
        (h_id, 'STD-DD',  'City Center Double',        'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 380, base * 0.95, 0.950, 180),
        (h_id, 'DLX-K',   'Executive King',            'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, TRUE,  420, base * 1.25, 1.250, 100),
        (h_id, 'STE-1BR', 'City Suite',                'suite',     2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, TRUE,  780, base * 1.90, 1.900, 30);

    -- ── RENAISSANCE DOWNTOWN (upscale, $215 base) ───────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'renaissance-downtown';
    base := 215.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Renaissance King',          'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, TRUE,  360, base * 1.00, 1.000, 100),
        (h_id, 'DLX-K',   'Deluxe City View King',     'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, TRUE,  400, base * 1.18, 1.180, 70),
        (h_id, 'STE-1BR', 'Renaissance Suite',         'suite',     2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  790, base * 1.88, 1.880, 18);

    -- ── JW MARRIOTT CHERRY CREEK (upscale, $240 base) ──────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'jw-marriott-cc';
    base := 240.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Deluxe King',               'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       TRUE,  TRUE,  420, base * 1.00, 1.000, 80),
        (h_id, 'DLX-K',   'Premium King',              'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      TRUE,  TRUE,  460, base * 1.18, 1.180, 60),
        (h_id, 'STE-1BR', 'Cherry Creek Suite',        'suite',     2, 'king',          TRUE,  'city',     TRUE,  'high',      TRUE,  TRUE,  920, base * 2.00, 2.000, 20);

    -- ── HYATT REGENCY DTC (upscale, $195 base) ──────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'hyatt-regency-dtc';
    base := 195.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Standard King',             'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 380, base * 1.00, 1.000, 180),
        (h_id, 'STD-DD',  'Standard Double',           'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 380, base * 0.95, 0.950, 120),
        (h_id, 'DLX-K',   'Regency Club King',         'deluxe',    2, 'king',          TRUE,  'mountain', FALSE, 'high',      FALSE, TRUE,  420, base * 1.28, 1.280, 80),
        (h_id, 'STE-1BR', 'DTC Suite',                 'suite',     2, 'king',          TRUE,  'mountain', FALSE, 'high',      TRUE,  TRUE,  820, base * 1.95, 1.950, 25);

    -- ── MIDSCALE DOWNTOWN (3 hotels, $140–$155 base) ────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'courtyard-downtown';
    base := 148.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Standard King',             'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 320, base * 1.00, 1.000, 90),
        (h_id, 'STD-DD',  'Standard Double Double',    'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 320, base * 0.95, 0.950, 55),
        (h_id, 'DLX-K',   'Deluxe King',               'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, FALSE, 360, base * 1.15, 1.150, 32);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'hampton-downtown';
    base := 138.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Hampton King',              'standard',  2, 'king',          FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 300, base * 1.00, 1.000, 100),
        (h_id, 'STD-DD',  'Hampton Double',            'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 300, base * 0.95, 0.950, 70),
        (h_id, 'STE-1BR', 'Hampton Suite',             'suite',     4, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 580, base * 1.60, 1.600, 32);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'hilton-garden-downtown';
    base := 142.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Garden King',               'standard',  2, 'king',          FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 310, base * 1.00, 1.000, 95),
        (h_id, 'STD-DD',  'Garden Double',             'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 310, base * 0.95, 0.950, 85),
        (h_id, 'DLX-K',   'City View King',            'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, FALSE, 350, base * 1.12, 1.120, 50);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'cambria-downtown';
    base := 152.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Cambria King',              'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, TRUE,  330, base * 1.00, 1.000, 90),
        (h_id, 'DLX-K',   'Cambria Deluxe King',       'deluxe',    2, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, TRUE,  370, base * 1.14, 1.140, 70),
        (h_id, 'STE-1BR', 'Cambria Suite',             'suite',     4, 'king',          TRUE,  'city',     FALSE, 'high',      FALSE, TRUE,  680, base * 1.75, 1.750, 25);

    -- ── AIRPORT HOTELS ──────────────────────────────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'westin-dia';
    base := 200.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Runway King',               'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, TRUE,  370, base * 1.00, 1.000, 220),
        (h_id, 'STD-DD',  'Runway Double',             'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'mid',       FALSE, TRUE,  370, base * 0.95, 0.950, 160),
        (h_id, 'DLX-K',   'Heavenly King',             'deluxe',    2, 'king',          TRUE,  'partial',  FALSE, 'high',      FALSE, TRUE,  420, base * 1.22, 1.220, 80),
        (h_id, 'STE-1BR', 'Westin Suite',              'suite',     2, 'king',          TRUE,  'partial',  FALSE, 'high',      TRUE,  TRUE,  820, base * 1.90, 1.900, 30);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'marriott-gateway';
    base := 145.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Gateway King',              'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 330, base * 1.00, 1.000, 120),
        (h_id, 'STD-DD',  'Gateway Double',            'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 330, base * 0.95, 0.950, 80),
        (h_id, 'STE-1BR', 'Gateway Suite',             'suite',     4, 'king',          FALSE, NULL,       FALSE, 'high',      FALSE, FALSE, 660, base * 1.65, 1.650, 20);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'aloft-gateway';
    base := 125.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Aloft King',                'standard',  2, 'king',          FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 295, base * 1.00, 1.000, 100),
        (h_id, 'STD-DD',  'Aloft Double',              'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 295, base * 0.92, 0.920, 68);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'hilton-airport';
    base := 140.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Hilton King',               'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 310, base * 1.00, 1.000, 130),
        (h_id, 'STD-DD',  'Hilton Double',             'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 310, base * 0.95, 0.950, 100),
        (h_id, 'STE-1BR', 'Executive Suite',           'suite',     4, 'king',          FALSE, NULL,       FALSE, 'high',      FALSE, FALSE, 640, base * 1.60, 1.600, 25);

    -- ── CHERRY CREEK MIDSCALE ────────────────────────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'hyatt-place-cc';
    base := 130.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Hyatt King',                'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 310, base * 1.00, 1.000, 80),
        (h_id, 'STE-1BR', 'Hyatt Place Suite',         'suite',     4, 'king',          FALSE, NULL,       FALSE, 'high',      FALSE, FALSE, 600, base * 1.55, 1.550, 35);

    -- ── TECH CENTER MIDSCALE ─────────────────────────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'embassy-dtc';
    base := 155.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Embassy King Suite',        'suite',     2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 550, base * 1.00, 1.000, 120),
        (h_id, 'STD-DD',  'Embassy Double Suite',      'suite',     4, 'double_double', FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 550, base * 0.95, 0.950, 80),
        (h_id, 'DLX-K',   'Premium King Suite',        'suite',     2, 'king',          TRUE,  'courtyard',FALSE, 'high',      FALSE, FALSE, 620, base * 1.18, 1.180, 36);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'courtyard-dtc';
    base := 118.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Standard King',             'standard',  2, 'king',          FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 305, base * 1.00, 1.000, 120),
        (h_id, 'STD-DD',  'Standard Double',           'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'mid',       FALSE, FALSE, 305, base * 0.95, 0.950, 95),
        (h_id, 'DLX-K',   'Deluxe King',               'deluxe',    2, 'king',          FALSE, NULL,       FALSE, 'high',      FALSE, FALSE, 340, base * 1.12, 1.120, 30);

    -- ── BUDGET ──────────────────────────────────────────────────────────────
    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'la-quinta-dia';
    base := 82.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Standard King',             'standard',  2, 'king',          FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 270, base * 1.00, 1.000, 80),
        (h_id, 'STD-DD',  'Standard Double',           'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 270, base * 0.95, 0.950, 69);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'comfort-suites-dtc';
    base := 88.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Studio King Suite',         'suite',     2, 'king',          FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 380, base * 1.00, 1.000, 70),
        (h_id, 'STD-DD',  'Studio Double Suite',       'suite',     4, 'double_double', FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 380, base * 0.95, 0.950, 58);

    SELECT id INTO h_id FROM hotel_ref WHERE slug = 'extended-stay-downtown';
    base := 75.00;
    INSERT INTO room_types (hotel_id, code, name, category, max_occupancy, bed_type, has_view, view_type, has_balcony, floor_level, has_minibar, has_premium_bedding, sq_ft, base_rate, rate_multiplier, quantity) VALUES
        (h_id, 'STD-K',   'Studio King',               'standard',  2, 'king',          FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 280, base * 1.00, 1.000, 70),
        (h_id, 'STD-DD',  'Studio Double',             'standard',  4, 'double_double', FALSE, NULL,       FALSE, 'low',       FALSE, FALSE, 280, base * 0.95, 0.950, 65);

END $$;
