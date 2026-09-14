-- Each method declares the result form its participants fill in.
--
-- Without this, shipping a cycle opened a TB Xpert Ultra result sheet for
-- every enrolled method - including microscopy and XDR, which are captured on
-- different forms entirely.
--
--   psql -U postgres -d moheqa -f migrations/002_method_result_form.sql

BEGIN;

ALTER TABLE methods ADD COLUMN IF NOT EXISTS result_form VARCHAR;

-- the only form built so far is CDL-PT-F-008, the Xpert MTB/RIF Ultra form
UPDATE methods SET result_form = 'tb_xpert_ultra' WHERE name = 'Ultra';

-- clear result sheets that were opened on the wrong form
DELETE FROM tb_xpert_ultra_results t
USING methods m
WHERE t.method_id = m.id
  AND (m.result_form IS DISTINCT FROM 'tb_xpert_ultra');

COMMIT;
