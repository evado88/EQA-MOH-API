-- 024_shipment_receipts.sql
-- Samples A-E arrive in a single package, so the arrival details (date
-- received, temperature on receipt, and any general comment) are recorded once
-- per shipment - that is, once per (pt_cycle_id, lab_id) - instead of being
-- repeated on every sample.
--
-- The per-sample suitability judgement stays on sample_receipts (one row per
-- sample), which from now on carries only the condition and its comment. The
-- arrival columns still present on sample_receipts (date_received,
-- temperature_c) are left in place but dormant to avoid a destructive change;
-- result entry for a sample is gated on BOTH a shipment receipt existing for
-- the (cycle, lab) and that sample's condition having been recorded.

CREATE TABLE IF NOT EXISTS shipment_receipts (
    id SERIAL PRIMARY KEY,
    pt_cycle_id INTEGER NOT NULL REFERENCES pt_cycles(id),
    lab_id INTEGER NOT NULL REFERENCES laboratorys(id),

    date_received DATE,
    temperature_c DOUBLE PRECISION, -- temperature on receipt, degrees Celsius
    comments VARCHAR,

    created_at TIMESTAMPTZ DEFAULT now(),
    created_by VARCHAR,
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR,

    UNIQUE (pt_cycle_id, lab_id)
);

-- Carry forward the arrival details already captured per sample into one
-- shipment row per (cycle, lab), preferring the most recently touched sample.
INSERT INTO shipment_receipts (pt_cycle_id, lab_id, date_received, temperature_c, created_by, created_at)
SELECT DISTINCT ON (pt_cycle_id, lab_id)
    pt_cycle_id, lab_id, date_received, temperature_c, created_by, created_at
FROM sample_receipts
ORDER BY pt_cycle_id, lab_id, updated_at DESC NULLS LAST, created_at DESC NULLS LAST
ON CONFLICT (pt_cycle_id, lab_id) DO NOTHING;
