-- Fractional evaluation scores.
--
-- Most graded fields score in whole marks, but the bacteriology AST section is
-- worth 20 marks split across the discs the participant was graded on, so a
-- participant who got five of six right scores 16.7, not 17. The scores were
-- integers; widen the two that carry a total so the stored score matches the
-- scheme's own analysis and the report prints the same number.
--
-- The reporting views read these columns, so they are dropped and recreated
-- around the type change (their definitions are unchanged, copied from
-- migration 007).
--
--   psql -U postgres -d moheqa -f migrations/027_fractional_scores.sql

BEGIN;

DROP VIEW IF EXISTS vw_pt_result_evaluation;
DROP VIEW IF EXISTS vw_pt_enrollment_performance;

ALTER TABLE pt_result_evaluations
    ALTER COLUMN score TYPE DOUBLE PRECISION;

ALTER TABLE pt_enrollment_performance
    ALTER COLUMN total_score TYPE DOUBLE PRECISION;

-- One row per graded sample per laboratory.
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

-- One row per participant per round.
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

COMMIT;
