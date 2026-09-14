-- The HIV-1 Viral Load result form, TF-009.
--
-- Reported by Virology PT (LMUTH) for the 'HIV-1 Viral Load- Conventional PCR'
-- scheme. Unlike the TB forms, a sample carries a single numeric result - the
-- viral load in log10 copies/ml - alongside the panel header the lab fills in
-- once per shipment.
--
--   psql -U postgres -d moheqa -f migrations/006_hiv_vl_results.sql

BEGIN;

CREATE TABLE IF NOT EXISTS hiv_vl_results (
    id                      SERIAL PRIMARY KEY,

    name                    VARCHAR NOT NULL,
    description             VARCHAR,

    scheme_id               INTEGER NOT NULL REFERENCES schemes(id),
    lab_id                  INTEGER NOT NULL REFERENCES laboratorys(id),
    service_id              INTEGER NOT NULL REFERENCES services(id),
    enrollment_id           INTEGER NOT NULL REFERENCES enrollments(id),
    pt_cycle_id             INTEGER NOT NULL REFERENCES pt_cycles(id),
    method_id               INTEGER NOT NULL REFERENCES methods(id),
    method_sample_id        INTEGER NOT NULL REFERENCES method_samples(id),

    -- panel header
    date_panel_received     DATE,
    date_tested             DATE,
    detection_assay         VARCHAR,
    extraction_assay        VARCHAR,
    assay_kit_lot_number    VARCHAR,
    assay_kit_expiry_date   DATE,
    assay_serial_number     VARCHAR,

    -- the result
    result_reported         VARCHAR,
    viral_load_log10        DOUBLE PRECISION,
    not_tested_reason       VARCHAR,

    -- sign off
    tested_by               VARCHAR,
    supervisor_name         VARCHAR,

    user_id                 INTEGER NOT NULL REFERENCES users(id),
    status_id               INTEGER NOT NULL REFERENCES list_statuses(id),
    stage_id                INTEGER NOT NULL REFERENCES list_stages(id),
    approval_levels         INTEGER NOT NULL,

    review1_at              TIMESTAMPTZ,
    review1_by              VARCHAR,
    review1_comments        VARCHAR,
    review2_at              TIMESTAMPTZ,
    review2_by              VARCHAR,
    review2_comments        VARCHAR,
    review3_at              TIMESTAMPTZ,
    review3_by              VARCHAR,
    review3_comments        VARCHAR,

    created_at              TIMESTAMPTZ,
    created_by              VARCHAR,
    updated_at              TIMESTAMPTZ,
    updated_by              VARCHAR
);

CREATE INDEX IF NOT EXISTS ix_hiv_vl_results_id ON hiv_vl_results (id);

-- one result per sample, per lab, per cycle
DO $$ BEGIN
    ALTER TABLE hiv_vl_results
        ADD CONSTRAINT uq_hiv_vl_results_cycle_lab_sample
        UNIQUE (pt_cycle_id, lab_id, method_sample_id);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

COMMIT;
