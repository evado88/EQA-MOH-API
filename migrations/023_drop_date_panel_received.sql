-- 023_drop_date_panel_received.sql
-- Drops the legacy per-result panel-received date now that the per-sample
-- receipt (sample_receipts.date_received) is the single source of truth for
-- when a sample was received. Only the HIV VL and EID result forms had it.
ALTER TABLE hiv_vl_results  DROP COLUMN IF EXISTS date_panel_received;
ALTER TABLE hiv_eid_results DROP COLUMN IF EXISTS date_panel_received;
