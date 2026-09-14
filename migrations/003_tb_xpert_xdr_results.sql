-- The Xpert MTB/XDR result form, CDL-PT-F-027.
--
-- The XDR assay reports a different panel to Ultra: TB detection is presence
-- or absence only, there are four drug resistance results (INH, FLQ, AMK, ETH)
-- and nine cycle threshold probes rather than six.
--
--   psql -U postgres -d moheqa -f migrations/003_tb_xpert_xdr_results.sql

BEGIN;

CREATE TABLE IF NOT EXISTS tb_xpert_xdr_results (
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

    date_tested             DATE,
    result_interpretable    VARCHAR,
    tb_detection_result     VARCHAR,

    -- isoniazid, fluoroquinolone, amikacin, ethionamide
    inh_result              VARCHAR,
    flq_result              VARCHAR,
    amk_result              VARCHAR,
    eth_result              VARCHAR,

    uninterpretable_result  VARCHAR,
    error_code              VARCHAR,

    -- cycle thresholds; lower case so raw SQL never has to quote them
    spc_ahpc                DOUBLE PRECISION,   -- SPC-ahpC
    inha                    DOUBLE PRECISION,   -- inhA
    katg                    DOUBLE PRECISION,   -- KatG
    fabg1                   DOUBLE PRECISION,   -- fabG1
    gyra1                   DOUBLE PRECISION,   -- gyrA1
    gyra2                   DOUBLE PRECISION,   -- gyrA2
    gyra3                   DOUBLE PRECISION,   -- gyrA3
    gyrb2                   DOUBLE PRECISION,   -- gyrB2
    rrs                     DOUBLE PRECISION,   -- rrs

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

CREATE INDEX IF NOT EXISTS ix_tb_xpert_xdr_results_id
    ON tb_xpert_xdr_results (id);

-- one result per sample, per lab, per cycle
DO $$ BEGIN
    ALTER TABLE tb_xpert_xdr_results
        ADD CONSTRAINT uq_tb_xpert_xdr_results_cycle_lab_sample
        UNIQUE (pt_cycle_id, lab_id, method_sample_id);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

-- the XDR method is now captured on its own form
UPDATE methods SET result_form = 'tb_xpert_xdr' WHERE name = 'XDR';

COMMIT;
