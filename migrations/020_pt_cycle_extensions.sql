-- 020_pt_cycle_extensions.sql
-- Lets an administrator extend a round's enrollment closing date or result
-- submission due date after it has (auto-)closed, and keeps an audit trail.
--
-- Because enrolment and result-capture windows are enforced live from the
-- dates, simply moving the date forward re-opens the window; this table records
-- who changed what, from when to when, why, and how many labs were notified.

CREATE TABLE IF NOT EXISTS pt_cycle_extensions (
    id SERIAL PRIMARY KEY,
    pt_cycle_id INTEGER NOT NULL REFERENCES pt_cycles(id) ON DELETE CASCADE,
    field VARCHAR NOT NULL,            -- 'closing_date' | 'result_submission_due_date'
    field_label VARCHAR,               -- human-readable label, snapshotted
    old_value DATE,
    new_value DATE NOT NULL,
    reason VARCHAR,
    recipients_notified INTEGER DEFAULT 0,
    extended_by VARCHAR,
    extended_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_pt_cycle_extensions_cycle ON pt_cycle_extensions (pt_cycle_id);
