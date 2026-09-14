-- The HIV-1 Early Infant Diagnosis result form, TF-012.
--
-- Reported by Virology PT (LMUTH) for the 'HIV EID-Conventional PCR' scheme.
-- Unlike the viral load form this one is qualitative: the participant reports
-- the exact phrase 'HIV-1 Detected' or 'HIV-1 Not Detected', with the CT/OD
-- and IC/QS values optional.
--
-- The panel also ships two kit controls. They are recorded on the form but
-- form TF-006 leaves them out of the evaluation table, so method_samples
-- gains a flag for them.
--
--   psql -U postgres -d moheqa -f migrations/008_hiv_eid_results.sql

BEGIN;

-- a kit control is shipped and recorded, but not scored
ALTER TABLE method_samples
    ADD COLUMN IF NOT EXISTS is_control BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS hiv_eid_results (
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

    -- panel header; EID asks for fewer details than the viral load form
    date_panel_received     DATE,
    date_tested             DATE,
    detection_assay         VARCHAR,
    extraction_assay        VARCHAR,
    assay_serial_number     VARCHAR,

    -- the result
    result_reported         VARCHAR,
    hiv_result              VARCHAR,
    hiv_ct_od_value         DOUBLE PRECISION,
    ic_qs_value             DOUBLE PRECISION,
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

CREATE INDEX IF NOT EXISTS ix_hiv_eid_results_id ON hiv_eid_results (id);

-- one result per sample, per lab, per cycle
DO $$ BEGIN
    ALTER TABLE hiv_eid_results
        ADD CONSTRAINT uq_hiv_eid_results_cycle_lab_sample
        UNIQUE (pt_cycle_id, lab_id, method_sample_id);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

COMMIT;
