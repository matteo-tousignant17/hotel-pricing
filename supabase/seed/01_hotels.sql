-- Stage 2 Seed: Denver Hotels
-- Uses a temp reference table so subsequent seed files can look up IDs by slug

CREATE TEMP TABLE hotel_ref (slug TEXT PRIMARY KEY, id UUID);

DO $$
DECLARE
    new_id UUID;
BEGIN

    -- ── LUXURY ─────────────────────────────────────────────────────────────
    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Four Seasons Hotel Denver', 'Four Seasons', 'luxury', 5.0, 4.5, 4.7, 3820,
        '1111 14th St, Denver, CO 80202', 'LoDo', 39.744200, -104.993800,
        0.30, 24.20, 0.10,
        TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, 49.00,
        TRUE, TRUE, NULL, 239)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('four-seasons', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('The Brown Palace Hotel and Spa', 'Autograph Collection', 'luxury', 4.5, 4.5, 4.6, 6140,
        '321 17th St, Denver, CO 80202', 'Downtown', 39.741800, -104.989200,
        0.50, 23.80, 0.50,
        FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, 45.00,
        FALSE, TRUE, 'Marriott Bonvoy', 241)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('brown-palace', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Kimpton Hotel Born', 'Kimpton', 'upscale', 4.0, 4.5, 4.6, 2890,
        '1600 Wewatta St, Denver, CO 80202', 'LoDo', 39.752100, -105.000400,
        0.80, 24.50, 0.20,
        FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, 52.00,
        TRUE, TRUE, 'IHG One Rewards', 200)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('kimpton-born', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('The Crawford Hotel at Union Station', NULL, 'upscale', 4.0, 4.5, 4.7, 1730,
        '1701 Wynkoop St, Denver, CO 80202', 'LoDo', 39.752900, -105.001200,
        0.70, 24.40, 0.05,
        FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, 48.00,
        FALSE, TRUE, NULL, 112)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('crawford-union', new_id);

    -- ── UPSCALE DOWNTOWN (LARGE CONVENTION) ────────────────────────────────
    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Hyatt Regency Denver at Colorado Convention Center', 'Hyatt Regency', 'upscale', 4.0, 4.0, 4.2, 8920,
        '650 15th St, Denver, CO 80202', 'Downtown', 39.741500, -104.995800,
        0.10, 23.60, 0.60,
        TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 42.00,
        FALSE, TRUE, 'World of Hyatt', 1100)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('hyatt-regency-dtw', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Sheraton Denver Downtown Hotel', 'Sheraton', 'upscale', 4.0, 3.5, 4.1, 9640,
        '1550 Court Pl, Denver, CO 80202', 'Downtown', 39.741900, -104.991600,
        0.40, 23.70, 0.70,
        TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 40.00,
        FALSE, TRUE, 'Marriott Bonvoy', 1231)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('sheraton-downtown', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Le Méridien Denver Downtown', 'Le Méridien', 'upscale', 4.0, 4.0, 4.3, 2140,
        '1475 California St, Denver, CO 80202', 'Downtown', 39.742800, -104.991000,
        0.45, 23.65, 0.65,
        TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, 44.00,
        TRUE, TRUE, 'Marriott Bonvoy', 292)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('le-meridien', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Denver Marriott City Center', 'Marriott', 'upscale', 4.0, 4.0, 4.2, 5480,
        '1701 California St, Denver, CO 80202', 'Downtown', 39.743100, -104.992400,
        0.35, 23.70, 0.70,
        TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 40.00,
        FALSE, TRUE, 'Marriott Bonvoy', 613)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('marriott-city-center', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Renaissance Denver Downtown City Center Hotel', 'Renaissance', 'upscale', 4.0, 4.0, 4.3, 3210,
        '918 17th St, Denver, CO 80202', 'Downtown', 39.742200, -104.988800,
        0.55, 23.75, 0.55,
        TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 41.00,
        FALSE, TRUE, 'Marriott Bonvoy', 230)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('renaissance-downtown', new_id);

    -- ── UPSCALE (MID-SIZE) ──────────────────────────────────────────────────
    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('JW Marriott Denver Cherry Creek', 'JW Marriott', 'upscale', 4.0, 4.5, 4.5, 3760,
        '150 Clayton Ln, Denver, CO 80206', 'Cherry Creek', 39.717900, -104.955800,
        3.10, 21.40, 3.20,
        TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, 38.00,
        TRUE, TRUE, 'Marriott Bonvoy', 196)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('jw-marriott-cc', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Hyatt Regency Denver Tech Center', 'Hyatt Regency', 'upscale', 4.0, 4.0, 4.2, 4120,
        '7800 E Tufts Ave, Denver, CO 80237', 'Tech Center', 39.645100, -104.898600,
        12.20, 19.30, 12.50,
        TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 35.00,
        TRUE, TRUE, 'World of Hyatt', 449)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('hyatt-regency-dtc', new_id);

    -- ── MIDSCALE DOWNTOWN ───────────────────────────────────────────────────
    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Courtyard by Marriott Denver Downtown', 'Courtyard', 'midscale', 3.5, 4.0, 4.2, 2680,
        '934 16th St Mall, Denver, CO 80202', 'Downtown', 39.742400, -104.990100,
        0.50, 23.80, 0.60,
        FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, 38.00,
        FALSE, TRUE, 'Marriott Bonvoy', 177)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('courtyard-downtown', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Hampton Inn and Suites Denver Downtown', 'Hampton Inn', 'midscale', 3.0, 4.0, 4.3, 3140,
        '550 15th St, Denver, CO 80202', 'Downtown', 39.741200, -104.995300,
        0.15, 23.60, 0.55,
        FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, 36.00,
        FALSE, FALSE, 'Hilton Honors', 202)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('hampton-downtown', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Hilton Garden Inn Denver Downtown', 'Hilton Garden Inn', 'midscale', 3.0, 4.0, 4.2, 2920,
        '1400 Welton St, Denver, CO 80202', 'Downtown', 39.743600, -104.988700,
        0.60, 23.90, 0.65,
        TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 37.00,
        FALSE, FALSE, 'Hilton Honors', 230)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('hilton-garden-downtown', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Cambria Hotel Denver Downtown', 'Cambria', 'midscale', 3.5, 4.0, 4.3, 1840,
        '1400 Curtis St, Denver, CO 80202', 'Downtown', 39.742900, -104.991800,
        0.40, 23.70, 0.60,
        FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, 40.00,
        TRUE, TRUE, 'Choice Privileges', 210)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('cambria-downtown', new_id);

    -- ── AIRPORT (DIA) ───────────────────────────────────────────────────────
    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Westin Denver International Airport', 'Westin', 'upscale', 4.0, 4.0, 4.3, 5620,
        '8300 Pena Blvd, Denver, CO 80249', 'Airport', 39.849300, -104.673200,
        23.10, 0.50, 24.80,
        TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, 30.00,
        FALSE, TRUE, 'Marriott Bonvoy', 519)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('westin-dia', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Marriott Denver Airport at Gateway Park', 'Marriott', 'midscale', 3.5, 4.0, 4.2, 3280,
        '16455 E 40th Ave, Aurora, CO 80011', 'Airport', 39.812400, -104.748600,
        23.40, 2.10, 24.20,
        TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, 0.00,
        FALSE, TRUE, 'Marriott Bonvoy', 238)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('marriott-gateway', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Aloft Denver Airport at Gateway Park', 'Aloft', 'midscale', 3.0, 4.0, 4.3, 2140,
        '16470 E 40th Ave, Aurora, CO 80011', 'Airport', 39.812100, -104.748200,
        23.50, 2.20, 24.30,
        TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, 0.00,
        FALSE, FALSE, 'Marriott Bonvoy', 168)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('aloft-gateway', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Hilton Denver Airport', 'Hilton', 'midscale', 3.5, 3.5, 4.1, 4810,
        '4411 Peoria St, Denver, CO 80239', 'Airport', 39.794600, -104.769800,
        23.80, 3.20, 24.60,
        TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, 0.00,
        FALSE, TRUE, 'Hilton Honors', 278)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('hilton-airport', new_id);

    -- ── CHERRY CREEK ────────────────────────────────────────────────────────
    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Hyatt Place Denver/Cherry Creek', 'Hyatt Place', 'midscale', 3.0, 4.0, 4.3, 1620,
        '222 S Columbine St, Denver, CO 80206', 'Cherry Creek', 39.718400, -104.955200,
        3.20, 21.50, 3.30,
        FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, 30.00,
        FALSE, FALSE, 'World of Hyatt', 152)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('hyatt-place-cc', new_id);

    -- ── TECH CENTER ─────────────────────────────────────────────────────────
    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Embassy Suites by Hilton Denver Tech Center', 'Embassy Suites', 'midscale', 3.5, 4.0, 4.3, 3480,
        '10250 E Costilla Ave, Centennial, CO 80112', 'Tech Center', 39.582100, -104.870900,
        13.80, 21.40, 14.10,
        TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, 0.00,
        FALSE, TRUE, 'Hilton Honors', 236)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('embassy-dtc', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Courtyard by Marriott Denver Tech Center', 'Courtyard', 'midscale', 3.0, 3.5, 4.0, 2140,
        '6565 S Yosemite St, Centennial, CO 80111', 'Tech Center', 39.613600, -104.888200,
        12.80, 20.10, 13.10,
        TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, 0.00,
        FALSE, TRUE, 'Marriott Bonvoy', 245)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('courtyard-dtc', new_id);

    -- ── BUDGET ──────────────────────────────────────────────────────────────
    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('La Quinta Inn by Wyndham Denver Airport', 'La Quinta', 'budget', 2.5, 3.5, 4.0, 2840,
        '3975 Peoria St, Aurora, CO 80010', 'Airport', 39.762800, -104.820600,
        23.90, 5.40, 24.70,
        TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, 0.00,
        FALSE, FALSE, 'Wyndham Rewards', 149)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('la-quinta-dia', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Comfort Suites Denver Tech Center', 'Comfort Suites', 'budget', 2.5, 3.5, 4.1, 1920,
        '7374 S Clinton St, Centennial, CO 80112', 'Tech Center', 39.581800, -104.866200,
        14.10, 21.60, 14.40,
        TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, 0.00,
        FALSE, FALSE, 'Choice Privileges', 128)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('comfort-suites-dtc', new_id);

    INSERT INTO hotels (name, brand, brand_tier, star_rating, tripadvisor_score, google_score, review_count,
        address, neighborhood, latitude, longitude,
        dist_convention_ctr_miles, dist_airport_miles, dist_lodo_miles,
        has_pool, has_spa, has_gym, has_restaurant, has_airport_shuttle, has_parking, parking_fee_nightly,
        has_ev_charging, has_business_center, loyalty_program, total_rooms)
    VALUES ('Extended Stay America Denver Downtown', 'Extended Stay America', 'budget', 2.0, 3.0, 3.8, 1480,
        '1545 Court Pl, Denver, CO 80202', 'Downtown', 39.741600, -104.991200,
        0.45, 23.75, 0.75,
        FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, 0.00,
        FALSE, FALSE, 'Extended Stay America Rewards', 135)
    RETURNING id INTO new_id;
    INSERT INTO hotel_ref VALUES ('extended-stay-downtown', new_id);

END $$;
