-- 022_sample_receipts.sql
-- Per-sample receipt details a laboratory records before entering results for
-- that sample (A1, A2, ...).
--
-- Keyed by (pt_cycle_id, lab_id, method_sample_id) - the same identity as a
-- result sheet - so it is shared across every result form rather than being
-- duplicated onto each of the five result tables. Result entry for a sample is
-- gated on a receipt existing for it (see the result update endpoints).

CREATE TABLE IF NOT EXISTS sample_receipts (
    id SERIAL PRIMARY KEY,
    pt_cycle_id INTEGER NOT NULL REFERENCES pt_cycles(id),
    lab_id INTEGER NOT NULL REFERENCES laboratorys(id),
    method_sample_id INTEGER NOT NULL REFERENCES method_samples(id),
    enrollment_id INTEGER REFERENCES enrollments(id),

    date_received DATE,
    condition VARCHAR,              -- 'Suitable' | 'Not suitable'
    temperature_c DOUBLE PRECISION, -- temperature on receipt, degrees Celsius
    comments VARCHAR,               -- required when condition is 'Not suitable'

    created_at TIMESTAMPTZ DEFAULT now(),
    created_by VARCHAR,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR,

    UNIQUE (pt_cycle_id, lab_id, method_sample_id)
);

CREATE INDEX IF NOT EXISTS ix_sample_receipts_cycle_lab ON sample_receipts (pt_cycle_id, lab_id);
