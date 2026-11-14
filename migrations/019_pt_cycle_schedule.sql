-- 019_pt_cycle_schedule.sql
-- Reworks the PT Cycle (round) around a full schedule of dates, with the
-- lifecycle status derived from those dates, and adds reminder tracking.
--
-- Dates captured: enrollment opening (effective_date, reused), enrollment
-- closing (closing_date, reused), sample shipping (shipping_date, reused but now
-- the PLANNED date - shipping itself is a manual action), test event start/stop,
-- result submission due, report availability (reports_availability_date, reused).
--
-- Two steps stay manual because of their side effects: marking samples shipped
-- (opens the result sheets) and publishing reports (runs the scoring). The rest
-- of the status - Upcoming / Enrolment Open / Enrolment Closed / Testing /
-- Results Due - is computed from the dates.

ALTER TABLE pt_cycles ADD COLUMN IF NOT EXISTS test_event_start_date DATE;
ALTER TABLE pt_cycles ADD COLUMN IF NOT EXISTS test_event_stop_date DATE;
ALTER TABLE pt_cycles ADD COLUMN IF NOT EXISTS result_submission_due_date DATE;
ALTER TABLE pt_cycles ADD COLUMN IF NOT EXISTS notes VARCHAR;

-- manual gates (with timestamps), replacing the old step-by-step status machine
ALTER TABLE pt_cycles ADD COLUMN IF NOT EXISTS samples_shipped BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE pt_cycles ADD COLUMN IF NOT EXISTS samples_shipped_at TIMESTAMPTZ;
ALTER TABLE pt_cycles ADD COLUMN IF NOT EXISTS reports_published BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE pt_cycles ADD COLUMN IF NOT EXISTS reports_published_at TIMESTAMPTZ;

-- the shipping date is now a plan, not a precondition, so it need not be set
ALTER TABLE pt_cycles ALTER COLUMN shipping_date DROP NOT NULL;

-- the date-derived status set (names updated in place; 6 and 7 added)
INSERT INTO pt_cycle_statuses (id, name, user_id, status_id, stage_id, approval_levels, created_by) VALUES
    (1, 'Upcoming',            1, 4, 5, 1, 'migration-019'),
    (2, 'Enrolment Open',      1, 4, 5, 1, 'migration-019'),
    (3, 'Enrolment Closed',    1, 4, 5, 1, 'migration-019'),
    (4, 'Samples Shipped',     1, 4, 5, 1, 'migration-019'),
    (5, 'Testing In Progress', 1, 4, 5, 1, 'migration-019'),
    (6, 'Results Due',         1, 4, 5, 1, 'migration-019'),
    (7, 'Report Available',    1, 4, 5, 1, 'migration-019')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

SELECT setval(pg_get_serial_sequence('pt_cycle_statuses', 'id'),
              GREATEST((SELECT MAX(id) FROM pt_cycle_statuses), 7));

-- which reminder emails have already gone out, so the daily job never repeats one
CREATE TABLE IF NOT EXISTS pt_cycle_reminders (
    id SERIAL PRIMARY KEY,
    pt_cycle_id INTEGER NOT NULL REFERENCES pt_cycles(id) ON DELETE CASCADE,
    reminder_key VARCHAR NOT NULL,   -- e.g. 'closing_date:7'
    recipients INTEGER,
    sent_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (pt_cycle_id, reminder_key)
);
