-- The evaluation layer, and the reporting views XtraReports binds to.
--
-- A PT report has to be reproducible. The statistics here are written once,
-- when a cycle moves to 'Report Available', and are never recomputed - so a
-- late or amended submission cannot silently rewrite a report already issued.
--
-- The three views at the bottom are the reporting surface. They are flat and
-- fully typed so the DevExpress Query Builder sees real columns with real
-- types: numeric aggregates, sorting and report parameters all behave.
--
--   psql -U postgres -d moheqa -f migrations/007_evaluation_layer.sql

BEGIN;

-- ---------------------------------------------------------- expected values

-- a manufactured panel states its own correct answer; a consensus panel
-- leaves it unstated and the value is derived from the participants
ALTER TABLE method_samples
    ADD COLUMN IF NOT EXISTS assigned_value_source VARCHAR;

ALTER TABLE pt_sample_statistics
    ADD COLUMN IF NOT EXISTS sample_group VARCHAR;

-- A sample is graded on more than one field - an Ultra sample is graded on
-- both TB Detection and Rif - so the stated value belongs per attribute, not
-- per sample.
ALTER TABLE method_samples
    DROP COLUMN IF EXISTS expected_value_numeric,
    DROP COLUMN IF EXISTS expected_value_text;

CREATE TABLE IF NOT EXISTS method_sample_expected_values (
    id                      SERIAL PRIMARY KEY,
    method_sample_id        INTEGER NOT NULL REFERENCES method_samples(id) ON DELETE CASCADE,
    attribute               VARCHAR NOT NULL,
    expected_value_numeric  DOUBLE PRECISION,
    expected_value_text     VARCHAR,
    created_at              TIMESTAMPTZ,
    created_by              VARCHAR,
    updated_at              TIMESTAMPTZ,
    updated_by              VARCHAR
);

DO $$ BEGIN
    ALTER TABLE method_sample_expected_values
        ADD CONSTRAINT uq_method_sample_expected_values_sample_attribute
        UNIQUE (method_sample_id, attribute);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------- statistics

CREATE TABLE IF NOT EXISTS pt_sample_statistics (
    id                      SERIAL PRIMARY KEY,

    pt_cycle_id             INTEGER NOT NULL REFERENCES pt_cycles(id),
    method_sample_id        INTEGER NOT NULL REFERENCES method_samples(id),
    sample_group            VARCHAR,
    method_id               INTEGER NOT NULL REFERENCES methods(id),
    service_id              INTEGER NOT NULL REFERENCES services(id),
    scheme_id               INTEGER NOT NULL REFERENCES schemes(id),

    result_form             VARCHAR NOT NULL,
    attribute               VARCHAR NOT NULL,
    attribute_label         VARCHAR,
    evaluation_kind         VARCHAR NOT NULL,

    assigned_value_numeric  DOUBLE PRECISION,
    assigned_value_text     VARCHAR,
    assigned_value_source   VARCHAR,

    participant_count       INTEGER NOT NULL DEFAULT 0,
    reported_count          INTEGER NOT NULL DEFAULT 0,

    group_mean              DOUBLE PRECISION,
    group_median            DOUBLE PRECISION,
    robust_sd               DOUBLE PRECISION,
    standard_sd             DOUBLE PRECISION,
    minimum_value           DOUBLE PRECISION,
    maximum_value           DOUBLE PRECISION,

    concordant_count        INTEGER,

    evaluated               BOOLEAN NOT NULL DEFAULT FALSE,
    not_evaluated_reason    VARCHAR,

    frozen_at               TIMESTAMPTZ,
    frozen_by               VARCHAR,

    created_at              TIMESTAMPTZ,
    created_by              VARCHAR,
    updated_at              TIMESTAMPTZ,
    updated_by              VARCHAR
);

DO $$ BEGIN
    ALTER TABLE pt_sample_statistics
        ADD CONSTRAINT uq_pt_sample_statistics_cycle_sample_attribute
        UNIQUE (pt_cycle_id, method_sample_id, attribute);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS ix_pt_sample_statistics_cycle
    ON pt_sample_statistics (pt_cycle_id);

-- ------------------------------------------------------------- per result

CREATE TABLE IF NOT EXISTS pt_result_evaluations (
    id                      SERIAL PRIMARY KEY,

    pt_cycle_id             INTEGER NOT NULL REFERENCES pt_cycles(id),
    lab_id                  INTEGER NOT NULL REFERENCES laboratorys(id),
    enrollment_id           INTEGER NOT NULL REFERENCES enrollments(id),
    method_sample_id        INTEGER NOT NULL REFERENCES method_samples(id),
    method_id               INTEGER NOT NULL REFERENCES methods(id),
    service_id              INTEGER NOT NULL REFERENCES services(id),
    scheme_id               INTEGER NOT NULL REFERENCES schemes(id),

    result_form             VARCHAR NOT NULL,
    result_id               INTEGER NOT NULL,
    attribute               VARCHAR NOT NULL,
    attribute_label         VARCHAR,

    reported_numeric        DOUBLE PRECISION,
    reported_text           VARCHAR,

    assigned_numeric        DOUBLE PRECISION,
    assigned_text           VARCHAR,
    group_mean              DOUBLE PRECISION,
    robust_sd               DOUBLE PRECISION,

    deviation               DOUBLE PRECISION,
    z_score                 DOUBLE PRECISION,
    score                   INTEGER NOT NULL DEFAULT 0,
    max_score               INTEGER NOT NULL DEFAULT 0,
    grade                   VARCHAR NOT NULL,

    evaluated               BOOLEAN NOT NULL DEFAULT FALSE,
    not_evaluated_reason    VARCHAR,

    frozen_at               TIMESTAMPTZ,
    frozen_by               VARCHAR,

    created_at              TIMESTAMPTZ,
    created_by              VARCHAR,
    updated_at              TIMESTAMPTZ,
    updated_by              VARCHAR
);

DO $$ BEGIN
    ALTER TABLE pt_result_evaluations
        ADD CONSTRAINT uq_pt_result_evaluations_result_attribute
        UNIQUE (result_form, result_id, attribute);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS ix_pt_result_evaluations_cycle_lab
    ON pt_result_evaluations (pt_cycle_id, lab_id);

-- ---------------------------------------------------------- per enrolment

CREATE TABLE IF NOT EXISTS pt_enrollment_performance (
    id                        SERIAL PRIMARY KEY,

    pt_cycle_id               INTEGER NOT NULL REFERENCES pt_cycles(id),
    lab_id                    INTEGER NOT NULL REFERENCES laboratorys(id),
    enrollment_id             INTEGER NOT NULL REFERENCES enrollments(id),
    method_id                 INTEGER NOT NULL REFERENCES methods(id),
    service_id                INTEGER NOT NULL REFERENCES services(id),
    scheme_id                 INTEGER NOT NULL REFERENCES schemes(id),

    result_form               VARCHAR NOT NULL,
    report_number             VARCHAR,

    attributes_total          INTEGER NOT NULL DEFAULT 0,
    attributes_evaluated      INTEGER NOT NULL DEFAULT 0,
    acceptable_count          INTEGER NOT NULL DEFAULT 0,
    warning_count             INTEGER NOT NULL DEFAULT 0,
    unacceptable_count        INTEGER NOT NULL DEFAULT 0,
    not_reported_count        INTEGER NOT NULL DEFAULT 0,

    total_score               INTEGER NOT NULL DEFAULT 0,
    max_score                 INTEGER NOT NULL DEFAULT 0,
    percent_score             DOUBLE PRECISION,

    overall_performance       VARCHAR NOT NULL,
    reason_for_no_evaluation  VARCHAR,

    frozen_at                 TIMESTAMPTZ,
    frozen_by                 VARCHAR,

    created_at                TIMESTAMPTZ,
    created_by                VARCHAR,
    updated_at                TIMESTAMPTZ,
    updated_by                VARCHAR
);

DO $$ BEGIN
    ALTER TABLE pt_enrollment_performance
        ADD CONSTRAINT uq_pt_enrollment_performance_enrollment
        UNIQUE (enrollment_id);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS ix_pt_enrollment_performance_cycle_lab
    ON pt_enrollment_performance (pt_cycle_id, lab_id);

-- ====================================================================
-- Reporting views - this is what XtraReports binds to
-- ====================================================================

-- One row per graded sample per laboratory. Drives the
-- 'Results of the Individual Evaluation' table on TF-007.
DROP VIEW IF EXISTS vw_pt_result_evaluation;
CREATE VIEW vw_pt_result_evaluation AS
SELECT
    e.id                            AS evaluation_id,
    e.pt_cycle_id,
    c.code                          AS cycle_code,
    c.name                          AS cycle_name,
    c.effective_date                AS shipment_date,
    c.closing_date                  AS shipment_target_date,
    c.shipping_date,
    c.reports_availability_date,

    p.id                            AS provider_id,
    p.name                          AS provider_name,
    sc.id                           AS scheme_id,
    sc.name                         AS scheme_name,
    sv.id                           AS service_id,
    sv.name                         AS service_name,
    m.id                            AS method_id,
    m.name                          AS method_name,
    e.result_form,

    e.lab_id,
    l.code                          AS lab_code,
    l.name                          AS lab_name,
    l.contact_person_name,
    l.email_address                 AS lab_email,
    l.phone_number                  AS lab_phone,
    prov.name                       AS province_name,
    d.name                          AS district_name,

    e.enrollment_id,
    e.method_sample_id,
    ms.name                         AS sample_name,

    e.attribute,
    e.attribute_label,
    st.evaluation_kind,

    e.reported_numeric,
    e.reported_text,
    e.assigned_numeric,
    e.assigned_text,
    st.assigned_value_source,

    st.participant_count,
    st.reported_count,
    st.group_mean,
    st.group_median,
    st.robust_sd,
    st.standard_sd,

    e.deviation,
    e.z_score,
    e.score,
    e.max_score,
    e.grade,
    e.evaluated,
    e.not_evaluated_reason,
    e.frozen_at
FROM pt_result_evaluations e
JOIN pt_cycles        c    ON c.id  = e.pt_cycle_id
JOIN schemes          sc   ON sc.id = e.scheme_id
JOIN providers        p    ON p.id  = sc.provider_id
JOIN services         sv   ON sv.id = e.service_id
JOIN methods          m    ON m.id  = e.method_id
JOIN method_samples   ms   ON ms.id = e.method_sample_id
JOIN laboratorys      l    ON l.id  = e.lab_id
LEFT JOIN provinces   prov ON prov.id = l.province_id
LEFT JOIN districts   d    ON d.id  = l.district_id
LEFT JOIN pt_sample_statistics st
       ON st.pt_cycle_id  = e.pt_cycle_id
      AND st.sample_group = ms.name
      AND st.attribute    = e.attribute;

-- One row per participant per round. Drives the report header, the
-- 'Laboratory Data' block and 'Overall performance'.
DROP VIEW IF EXISTS vw_pt_enrollment_performance;
CREATE VIEW vw_pt_enrollment_performance AS
SELECT
    pf.id                           AS performance_id,
    pf.report_number,
    pf.pt_cycle_id,
    c.code                          AS cycle_code,
    c.name                          AS cycle_name,
    c.effective_date                AS shipment_date,
    c.closing_date                  AS shipment_target_date,
    c.shipping_date,
    c.reports_availability_date     AS report_date,
    cs.name                         AS cycle_status,

    p.id                            AS provider_id,
    p.name                          AS provider_name,
    sc.id                           AS scheme_id,
    sc.name                         AS scheme_name,
    sv.id                           AS service_id,
    sv.name                         AS service_name,
    m.id                            AS method_id,
    m.name                          AS method_name,
    pf.result_form,

    pf.lab_id,
    l.code                          AS lab_code,
    l.name                          AS lab_name,
    l.contact_person_name,
    l.email_address                 AS lab_email,
    l.phone_number                  AS lab_phone,
    l.physical_address,
    lt.name                         AS lab_type,
    prov.name                       AS province_name,
    d.name                          AS district_name,

    pf.enrollment_id,
    en.samples_received_at,

    pf.attributes_total,
    pf.attributes_evaluated,
    pf.acceptable_count,
    pf.warning_count,
    pf.unacceptable_count,
    pf.not_reported_count,
    pf.total_score,
    pf.max_score,
    pf.percent_score,
    round((pf.percent_score * 100)::numeric, 1) AS percent_score_display,
    pf.overall_performance,
    pf.reason_for_no_evaluation,
    pf.frozen_at
FROM pt_enrollment_performance pf
JOIN pt_cycles          c    ON c.id  = pf.pt_cycle_id
JOIN pt_cycle_statuses  cs   ON cs.id = c.pt_cyle_status_id
JOIN schemes            sc   ON sc.id = pf.scheme_id
JOIN providers          p    ON p.id  = sc.provider_id
JOIN services           sv   ON sv.id = pf.service_id
JOIN methods            m    ON m.id  = pf.method_id
JOIN laboratorys        l    ON l.id  = pf.lab_id
LEFT JOIN lab_types     lt   ON lt.id = l.lab_type_id
LEFT JOIN provinces     prov ON prov.id = l.province_id
LEFT JOIN districts     d    ON d.id  = l.district_id
JOIN enrollments        en   ON en.id = pf.enrollment_id;

-- One row per sample per method. Drives the 'Summary of performance'
-- cross-tab, which counts participants and outcomes per platform.
DROP VIEW IF EXISTS vw_pt_sample_summary;
CREATE VIEW vw_pt_sample_summary AS
SELECT
    e.pt_cycle_id,
    c.code                              AS cycle_code,
    sc.id                               AS scheme_id,
    sc.name                             AS scheme_name,
    sv.name                             AS service_name,
    m.id                                AS method_id,
    m.name                              AS method_name,
    e.result_form,
    e.method_sample_id,
    ms.name                             AS sample_name,
    e.attribute,
    e.attribute_label,

    -- pooled across every platform that ran this material
    max(st.evaluation_kind)             AS evaluation_kind,
    max(st.assigned_value_numeric)      AS assigned_value_numeric,
    max(st.assigned_value_text)         AS assigned_value_text,
    max(st.assigned_value_source)       AS assigned_value_source,
    max(st.participant_count)           AS pooled_participant_count,
    max(st.reported_count)              AS pooled_reported_count,
    max(st.group_mean)                  AS group_mean,
    max(st.group_median)                AS group_median,
    max(st.robust_sd)                   AS robust_sd,
    max(st.standard_sd)                 AS standard_sd,
    max(st.minimum_value)               AS minimum_value,
    max(st.maximum_value)               AS maximum_value,
    bool_or(st.evaluated)               AS evaluated,
    max(st.not_evaluated_reason)        AS not_evaluated_reason,

    -- this platform only, which is what the cross-tab counts
    count(*)                                            AS participant_count,
    count(*) FILTER (WHERE e.evaluated)                 AS evaluated_count,
    count(*) FILTER (WHERE e.grade = 'Acceptable')      AS acceptable_count,
    count(*) FILTER (WHERE e.grade = 'Warning')         AS warning_count,
    count(*) FILTER (WHERE e.grade = 'Unacceptable')    AS unacceptable_count,
    count(*) FILTER (WHERE NOT e.evaluated)             AS not_evaluated_count,
    count(*) FILTER (WHERE e.reported_text = 'DETECTED')     AS detected_count,
    count(*) FILTER (WHERE e.reported_text = 'NOT DETECTED') AS not_detected_count,
    avg(e.reported_numeric)                             AS platform_mean,
    max(st.frozen_at)                                   AS frozen_at
FROM pt_result_evaluations e
JOIN pt_cycles        c  ON c.id  = e.pt_cycle_id
JOIN schemes          sc ON sc.id = e.scheme_id
JOIN services         sv ON sv.id = e.service_id
JOIN methods          m  ON m.id  = e.method_id
JOIN method_samples   ms ON ms.id = e.method_sample_id
LEFT JOIN pt_sample_statistics st
       ON st.pt_cycle_id  = e.pt_cycle_id
      AND st.sample_group = ms.name
      AND st.attribute    = e.attribute
GROUP BY
    e.pt_cycle_id, c.code, sc.id, sc.name, sv.name, m.id, m.name,
    e.result_form, e.method_sample_id, ms.name, e.attribute, e.attribute_label;

COMMIT;
