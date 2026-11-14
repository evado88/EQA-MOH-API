-- 021_result_submissions.sql
-- Audit trail of laboratory result submissions.
--
-- Result submission no longer needs provider approval: a lab submits (and may
-- resubmit) until the round's result submission due date, after which the
-- window closes. This table records every submission for audit - which result
-- sheet, for which lab/cycle/sample, who submitted it and when, and the running
-- submission number.

CREATE TABLE IF NOT EXISTS result_submissions (
    id SERIAL PRIMARY KEY,
    result_form VARCHAR NOT NULL,      -- tb_xpert_ultra, hiv_vl, bacteriology, ...
    result_id INTEGER NOT NULL,        -- id within that form's result table
    lab_id INTEGER,
    pt_cycle_id INTEGER,
    scheme_id INTEGER,
    method_sample_id INTEGER,
    submission_no INTEGER,             -- 1 for the first submission, 2 for the next, ...
    submitted_by VARCHAR,
    submitted_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_result_submissions_result ON result_submissions (result_form, result_id);
CREATE INDEX IF NOT EXISTS ix_result_submissions_cycle ON result_submissions (pt_cycle_id);
CREATE INDEX IF NOT EXISTS ix_result_submissions_lab ON result_submissions (lab_id);
