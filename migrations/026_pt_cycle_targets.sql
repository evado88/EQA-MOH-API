-- Per-round targets (expected values).
--
-- The stated correct answer for a sample ('the target') used to be keyed on the
-- method sample alone. But a method sample is a static catalogue entry reused
-- every round - 'Sample E' is shipped cycle after cycle - so a target keyed to
-- it would apply to every round at once. A target is a property of the ROUND:
-- this round's Sample E is Klebsiella pneumoniae, next round's is something else.
--
-- So method_sample_expected_values gains a pt_cycle_id:
--   * a row WITH a cycle is that round's target (what the coordinator enters per
--     round, and what the analysis grades against first)
--   * a row WITHOUT a cycle (NULL) stays the per-sample default, for a panel
--     whose material never changes - kept so existing data still grades.
--
-- The evaluation prefers the cycle-specific target and falls back to the NULL
-- default. Two partial unique indexes keep each unique in its own space (a plain
-- UNIQUE would let many NULL-cycle rows collide, since NULLs are distinct).
--
--   psql -U postgres -d moheqa -f migrations/026_pt_cycle_targets.sql

BEGIN;

ALTER TABLE method_sample_expected_values
    ADD COLUMN IF NOT EXISTS pt_cycle_id INTEGER
        REFERENCES pt_cycles(id) ON DELETE CASCADE;

-- the old whole-table unique no longer fits: the same sample+attribute may now
-- carry one default row and one row per round
ALTER TABLE method_sample_expected_values
    DROP CONSTRAINT IF EXISTS uq_method_sample_expected_values_sample_attribute;

-- one target per sample+attribute within a round
CREATE UNIQUE INDEX IF NOT EXISTS uq_mse_values_cycle_sample_attribute
    ON method_sample_expected_values (pt_cycle_id, method_sample_id, attribute)
    WHERE pt_cycle_id IS NOT NULL;

-- one default target per sample+attribute (the round-less fallback)
CREATE UNIQUE INDEX IF NOT EXISTS uq_mse_values_default_sample_attribute
    ON method_sample_expected_values (method_sample_id, attribute)
    WHERE pt_cycle_id IS NULL;

CREATE INDEX IF NOT EXISTS ix_mse_values_cycle
    ON method_sample_expected_values (pt_cycle_id);

COMMIT;
