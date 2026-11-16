-- 025_bacteriology_date_tested.sql
-- Bacteriology had no "date tested" field (unlike the molecular forms, which
-- carry date_tested). Its manual "Date of Submission" (date_submitted) was
-- redundant with the automatic submission audit in result_submissions, so it is
-- repurposed into the missing test date: rename date_submitted -> date_tested.

ALTER TABLE bacteriology_results RENAME COLUMN date_submitted TO date_tested;
