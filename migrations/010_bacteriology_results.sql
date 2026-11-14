-- The NHRTI Bacteriology worksheet, TF-NHRTI-BACT-001.
--
-- One worksheet per specimen, not per test. The worksheet carries three
-- sections - the Gram stain, the final organism identification and the
-- antimicrobial susceptibility testing - and scheme protocol
-- TP-NHRTI-BACT-001 scores all three together, out of 100, as a single
-- standing per participant:
--
--     Gram stain reaction      3 x 5 samples =  15
--     Bacterial morphology     3 x 5 samples =  15
--     Bacterial identification 10 x 5 samples = 50
--     AST (tested discs)       20 x 1 sample  = 20
--                                              ---
--                                              100, and 100% is the bar
--
-- That single total is why the whole worksheet is one result form rather than
-- one per test: three forms would give a laboratory three separate standings
-- and never the /100 the protocol requires.
--
-- The AST section is a table of up to fifteen antibiotics, twice over - once
-- for disk diffusion and once for MIC - so it is a child table rather than
-- columns on the worksheet.
--
--   psql -U postgres -d moheqa -f migrations/010_bacteriology_results.sql

BEGIN;

CREATE TABLE IF NOT EXISTS bacteriology_results (
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

    -- worksheet header. The survey number, sample number, laboratory code and
    -- trial closing date are printed on the form but are already held by the
    -- cycle, the sample and the laboratory, so only what the participant
    -- writes in is stored here.
    date_samples_received   DATE,
    receipt_temperature     DOUBLE PRECISION,
    sample_condition        VARCHAR,
    sample_condition_reason VARCHAR,
    date_submitted          DATE,

    -- the participant could not work the specimen at all
    testing_not_done        BOOLEAN NOT NULL DEFAULT FALSE,
    testing_not_done_reason VARCHAR,

    -- microscopy (Gram stain)
    gram_stain_reaction     VARCHAR,
    gram_morphology         VARCHAR,
    gram_morphology_other   VARCHAR,
    microscopy_comment      VARCHAR,

    -- final organism identification
    organism_identified     VARCHAR,
    identification_comment  VARCHAR,

    -- antimicrobial susceptibility testing; the rows live in
    -- bacteriology_ast_results
    ast_performed           BOOLEAN NOT NULL DEFAULT FALSE,
    ast_guideline           VARCHAR,
    ast_disk_diffusion      BOOLEAN NOT NULL DEFAULT FALSE,
    ast_mic_method          VARCHAR,
    ast_mic_method_other    VARCHAR,

    comments                VARCHAR,

    -- sign off
    reported_by             VARCHAR,
    reported_on             DATE,
    reviewed_by             VARCHAR,
    reviewed_on             DATE,

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

CREATE INDEX IF NOT EXISTS ix_bacteriology_results_id ON bacteriology_results (id);

-- one worksheet per sample, per lab, per cycle
DO $$ BEGIN
    ALTER TABLE bacteriology_results
        ADD CONSTRAINT uq_bacteriology_results_cycle_lab_sample
        UNIQUE (pt_cycle_id, lab_id, method_sample_id);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;


-- The AST table on the worksheet: fifteen numbered rows for disk diffusion
-- and fifteen for MIC, each an antibiotic, a reading and an interpretation.
-- A row the participant left blank is simply never written.
CREATE TABLE IF NOT EXISTS bacteriology_ast_results (
    id                      SERIAL PRIMARY KEY,

    bacteriology_result_id  INTEGER NOT NULL
                            REFERENCES bacteriology_results(id) ON DELETE CASCADE,

    -- which of the two tables the row was read off
    ast_method              VARCHAR NOT NULL,
    row_no                  INTEGER NOT NULL,

    antibiotic              VARCHAR NOT NULL,
    -- disk diffusion reports a zone in millimetres; MIC reports a
    -- concentration, which is written with an operator ('<=0.5', '>2') and so
    -- is text rather than a number
    zone_diameter           DOUBLE PRECISION,
    mic_reading             VARCHAR,
    interpretation          VARCHAR,

    created_at              TIMESTAMPTZ,
    created_by              VARCHAR,
    updated_at              TIMESTAMPTZ,
    updated_by              VARCHAR
);

CREATE INDEX IF NOT EXISTS ix_bacteriology_ast_results_id
    ON bacteriology_ast_results (id);
CREATE INDEX IF NOT EXISTS ix_bacteriology_ast_results_result
    ON bacteriology_ast_results (bacteriology_result_id);

-- An antibiotic is reported once per method on a worksheet, and a row number
-- is used once per method.
--
-- Both are deferred to commit. The participant fills the table in as a whole,
-- so saving a worksheet replaces the table rather than editing it row by row,
-- and the new rows are written before the old ones have gone. Checked per
-- statement, re-numbering row 2 as row 1 would collide with the row 1 that is
-- about to be deleted; checked at commit, only the table that was actually
-- saved has to be unique.
ALTER TABLE bacteriology_ast_results
    DROP CONSTRAINT IF EXISTS uq_bacteriology_ast_results_result_method_row;
ALTER TABLE bacteriology_ast_results
    ADD CONSTRAINT uq_bacteriology_ast_results_result_method_row
    UNIQUE (bacteriology_result_id, ast_method, row_no)
    DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE bacteriology_ast_results
    DROP CONSTRAINT IF EXISTS uq_bacteriology_ast_results_result_method_antibiotic;
ALTER TABLE bacteriology_ast_results
    ADD CONSTRAINT uq_bacteriology_ast_results_result_method_antibiotic
    UNIQUE (bacteriology_result_id, ast_method, antibiotic)
    DEFERRABLE INITIALLY DEFERRED;

COMMIT;
