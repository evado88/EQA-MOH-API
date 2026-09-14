-- EQA workflow migration
--
-- Base.metadata.create_all only ever CREATEs missing tables, it never ALTERs an
-- existing one. Run this once against an existing 'moheqa' database to bring it
-- in line with the models. It is safe to re-run.
--
--   psql -U postgres -d moheqa -f migrations/001_eqa_workflow.sql

BEGIN;

-- ---------------------------------------------------------------- new columns

-- a lab records when the shipped panel actually arrived
ALTER TABLE enrollments
    ADD COLUMN IF NOT EXISTS samples_received_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS samples_received_by VARCHAR;

-- the date tested and error code columns on form CDL-PT-F-008
ALTER TABLE tb_xpert_ultra_results
    ADD COLUMN IF NOT EXISTS date_tested DATE,
    ADD COLUMN IF NOT EXISTS error_code VARCHAR;

-- ------------------------------------------------------------ relaxed columns

-- a self registering lab has no owning user until an admin approves it
ALTER TABLE laboratorys ALTER COLUMN user_id DROP NOT NULL;
ALTER TABLE applications ALTER COLUMN user_id DROP NOT NULL;

-- ---------------------------------------------------------- unique constraints
-- Each of these may fail if the existing data already violates it. Clean the
-- duplicates up first, then re-run - do not drop the constraint.

DO $$
BEGIN
    -- the scheme catalogue: provider -> scheme -> service -> method -> sample
    ALTER TABLE providers ADD CONSTRAINT uq_providers_name UNIQUE (name);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    ALTER TABLE schemes ADD CONSTRAINT uq_schemes_provider_name UNIQUE (provider_id, name);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE services ADD CONSTRAINT uq_services_scheme_name UNIQUE (scheme_id, name);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE methods ADD CONSTRAINT uq_methods_service_name UNIQUE (service_id, name);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE method_samples ADD CONSTRAINT uq_method_samples_method_name UNIQUE (method_id, name);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

-- the participation chain: registration -> application -> enrolment -> result
DO $$ BEGIN
    ALTER TABLE laboratorys ADD CONSTRAINT uq_laboratorys_code UNIQUE (code);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE laboratorys ADD CONSTRAINT uq_laboratorys_email_address UNIQUE (email_address);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE applications ADD CONSTRAINT uq_applications_lab_method UNIQUE (lab_id, method_id);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE pt_cycles ADD CONSTRAINT uq_pt_cycles_scheme_code UNIQUE (scheme_id, code);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE enrollments ADD CONSTRAINT uq_enrollments_cycle_lab_method UNIQUE (pt_cycle_id, lab_id, method_id);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE tb_xpert_ultra_results ADD CONSTRAINT uq_tb_xpert_ultra_results_cycle_lab_sample UNIQUE (pt_cycle_id, lab_id, method_sample_id);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

-- the dictionaries
DO $$ BEGIN
    ALTER TABLE roles ADD CONSTRAINT uq_roles_name UNIQUE (name);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE pt_cycle_statuses ADD CONSTRAINT uq_pt_cycle_statuses_name UNIQUE (name);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE lab_types ADD CONSTRAINT uq_lab_types_name UNIQUE (name);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------------- back fill

-- labs approved before this change were given role 9 without being linked to
-- their laboratory, which left them unable to see their own results
UPDATE users u
SET laboratory_id = l.id
FROM laboratorys l
WHERE u.laboratory_id IS NULL
  AND u.role_id IN (9, 10)
  AND lower(l.email_address) = lower(u.email);

COMMIT;
