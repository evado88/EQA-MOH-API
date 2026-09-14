-- Corrects the spelling of the Ultra result's interpretable column.
--
-- The column was created as 'result_nterpretable', missing the leading 'i'.
-- The XDR form added later spells it correctly, so the two sibling tables
-- disagreed by one letter - an easy trap when copying code between them.
--
--   psql -U postgres -d moheqa -f migrations/004_fix_result_interpretable_spelling.sql

BEGIN;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tb_xpert_ultra_results'
          AND column_name = 'result_nterpretable'
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tb_xpert_ultra_results'
          AND column_name = 'result_interpretable'
    ) THEN
        ALTER TABLE tb_xpert_ultra_results
            RENAME COLUMN result_nterpretable TO result_interpretable;
    END IF;
END $$;

COMMIT;
