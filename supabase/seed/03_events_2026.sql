-- Stage 2 Seed: Denver Event Calendar 2026
-- Covers Jun 2026 – Jan 2027 to give 90+ days of event context

INSERT INTO events (name, event_type, venue, start_date, end_date, demand_impact, estimated_attendance, affected_neighborhoods, notes) VALUES

-- ── HOLIDAYS ──────────────────────────────────────────────────────────────
('Independence Day', 'holiday', NULL, '2026-07-04', '2026-07-04', 'high', NULL,
    ARRAY['LoDo', 'Downtown', 'RiNo', 'Capitol Hill'], 'Fireworks at Civic Center Park; weekend effect spills Fri–Sun'),

('Labor Day Weekend', 'holiday', NULL, '2026-09-05', '2026-09-07', 'medium', NULL,
    ARRAY['LoDo', 'Downtown', 'Cherry Creek'], 'Final summer weekend; strong leisure demand'),

('Thanksgiving Weekend', 'holiday', NULL, '2026-11-26', '2026-11-29', 'medium', NULL,
    ARRAY['LoDo', 'Downtown', 'Airport'], 'Mixed travel patterns; airport hotels spike Thu–Sun'),

('Christmas Week', 'holiday', NULL, '2026-12-24', '2026-12-27', 'high', NULL,
    ARRAY['LoDo', 'Downtown', 'Cherry Creek', 'Airport'], 'Ski-adjacent demand plus family travel'),

('New Year''s Eve', 'holiday', NULL, '2026-12-31', '2027-01-01', 'high', 200000,
    ARRAY['LoDo', 'Downtown', 'RiNo', 'Capitol Hill'], 'Largest single-night demand spike of the year'),

-- ── DENVER BRONCOS HOME GAMES (2026 season, approximate) ──────────────────
('Broncos Home Game vs Raiders', 'sports', 'Empower Field at Mile High', '2026-09-13', '2026-09-13', 'high', 76125,
    ARRAY['LoDo', 'Downtown', 'RiNo'], 'Week 1 home opener; highest demand of NFL schedule'),

('Broncos Home Game vs Chargers', 'sports', 'Empower Field at Mile High', '2026-09-27', '2026-09-27', 'high', 76125,
    ARRAY['LoDo', 'Downtown', 'RiNo'], NULL),

('Broncos Home Game vs Chiefs', 'sports', 'Empower Field at Mile High', '2026-10-11', '2026-10-11', 'high', 76125,
    ARRAY['LoDo', 'Downtown', 'RiNo'], 'AFC West rivalry; highest-demand Broncos game'),

('Broncos Home Game vs Steelers', 'sports', 'Empower Field at Mile High', '2026-10-25', '2026-10-25', 'high', 76125,
    ARRAY['LoDo', 'Downtown', 'RiNo'], NULL),

('Broncos Home Game vs Jets', 'sports', 'Empower Field at Mile High', '2026-11-08', '2026-11-08', 'high', 76125,
    ARRAY['LoDo', 'Downtown', 'RiNo'], NULL),

('Broncos Home Game vs Cowboys', 'sports', 'Empower Field at Mile High', '2026-11-22', '2026-11-22', 'high', 76125,
    ARRAY['LoDo', 'Downtown', 'RiNo'], 'Thanksgiving week prime-time game'),

('Broncos Home Game vs Raiders (2)', 'sports', 'Empower Field at Mile High', '2026-12-13', '2026-12-13', 'high', 76125,
    ARRAY['LoDo', 'Downtown', 'RiNo'], NULL),

('Broncos Home Game vs Bengals', 'sports', 'Empower Field at Mile High', '2026-12-27', '2026-12-27', 'high', 76125,
    ARRAY['LoDo', 'Downtown', 'RiNo'], 'Late-season playoff push game'),

-- ── COLORADO ROCKIES (select weekend series) ─────────────────────────────
('Rockies vs Cubs Series', 'sports', 'Coors Field', '2026-07-10', '2026-07-12', 'medium', 45000,
    ARRAY['LoDo', 'Downtown', 'RiNo'], 'Weekend series; incremental demand on top of summer baseline'),

('Rockies vs Dodgers Series', 'sports', 'Coors Field', '2026-08-14', '2026-08-16', 'medium', 48000,
    ARRAY['LoDo', 'Downtown', 'RiNo'], 'High-profile series; traveling LA fans'),

-- ── DENVER NUGGETS (preseason / early season) ────────────────────────────
('Nuggets Home Opener', 'sports', 'Ball Arena', '2026-10-21', '2026-10-21', 'medium', 19520,
    ARRAY['LoDo', 'Downtown'], NULL),

('Nuggets vs Lakers', 'sports', 'Ball Arena', '2026-11-18', '2026-11-18', 'medium', 19520,
    ARRAY['LoDo', 'Downtown'], 'High-profile matchup; traveling LA fans'),

-- ── CONVENTIONS (Colorado Convention Center) ──────────────────────────────
('Denver Tech Summit 2026', 'convention', 'Colorado Convention Center', '2026-07-21', '2026-07-23', 'citywide', 18000,
    ARRAY['Downtown', 'LoDo', 'Cherry Creek'], 'Major tech conference; fills all downtown hotels'),

('Natural Products Expo Mountain West', 'convention', 'Colorado Convention Center', '2026-08-04', '2026-08-06', 'citywide', 12000,
    ARRAY['Downtown', 'LoDo', 'Cherry Creek'], NULL),

('Healthcare Innovation Summit', 'convention', 'Colorado Convention Center', '2026-09-15', '2026-09-17', 'citywide', 15000,
    ARRAY['Downtown', 'LoDo', 'Cherry Creek'], NULL),

('Denver Business Innovation Expo', 'convention', 'Colorado Convention Center', '2026-10-06', '2026-10-08', 'citywide', 20000,
    ARRAY['Downtown', 'LoDo', 'Cherry Creek'], NULL),

-- ── FESTIVALS ────────────────────────────────────────────────────────────
('Denver Pride Festival', 'festival', 'Civic Center Park', '2026-06-20', '2026-06-21', 'medium', 500000,
    ARRAY['Capitol Hill', 'Downtown', 'LoDo'], 'One of largest pride events in the mountain west'),

('Cherry Creek Arts Festival', 'festival', 'Cherry Creek North', '2026-07-03', '2026-07-05', 'medium', 350000,
    ARRAY['Cherry Creek'], 'Overlaps with 4th of July weekend; Cherry Creek hotels surge'),

('Taste of Colorado', 'festival', 'Civic Center Park', '2026-09-04', '2026-09-07', 'medium', 500000,
    ARRAY['Downtown', 'Capitol Hill', 'LoDo'], 'Labor Day weekend food festival'),

('Great American Beer Festival', 'festival', 'Colorado Convention Center', '2026-10-01', '2026-10-03', 'high', 60000,
    ARRAY['Downtown', 'LoDo', 'RiNo'], 'Sells out within hours; one of Denver''s signature events'),

('Denver Film Festival', 'festival', 'Denver Film Center', '2026-11-04', '2026-11-15', 'low', 45000,
    ARRAY['Downtown', 'Capitol Hill'], 'Extended run; moderate incremental demand'),

-- ── NATIONAL WESTERN STOCK SHOW (Jan 2027 — seed for forward planning) ────
('National Western Stock Show 2027', 'convention', 'National Western Complex', '2027-01-10', '2027-01-25', 'citywide', 700000,
    ARRAY['Downtown', 'LoDo', 'Airport', 'RiNo'], 'Largest single event in Denver; 16-day citywide demand spike');
