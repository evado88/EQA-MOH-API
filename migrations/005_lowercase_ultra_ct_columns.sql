-- Lower-cases the Ultra cycle threshold columns.
--
-- Postgres folds unquoted identifiers to lower case, so a mixed-case column
-- has to be written "rpoB1" in every hand-written query or reporting tool -
-- and silently fails with a confusing "column rpob1 does not exist" if it is
-- not. The XDR form added later uses lower-case names for this reason; this
-- brings Ultra into line.
--
-- Only the identifiers change. The form spelling (IS1081-IS6110, rpoB1 ...)
-- is unchanged and still what the UI displays.
--
--   psql -U postgres -d moheqa -f migrations/005_lowercase_ultra_ct_columns.sql

BEGIN;

DO $$
DECLARE
    pair RECORD;
BEGIN
    FOR pair IN
        SELECT * FROM (VALUES
            ('is1081_IS6110', 'is1081_is6110'),
            ('rpoB1', 'rpob1'),
            ('rpoB2', 'rpob2'),
            ('rpoB3', 'rpob3'),
            ('rpoB4', 'rpob4')
        ) AS t(old_name, new_name)
    LOOP
        IF EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'tb_xpert_ultra_results'
              AND column_name = pair.old_name
        ) AND NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'tb_xpert_ultra_results'
              AND column_name = pair.new_name
        ) THEN
            EXECUTE format(
                'ALTER TABLE tb_xpert_ultra_results RENAME COLUMN %I TO %I',
                pair.old_name, pair.new_name);
        END IF;
    END LOOP;
END $$;

COMMIT;
