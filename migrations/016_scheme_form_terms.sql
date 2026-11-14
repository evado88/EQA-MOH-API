-- 016_scheme_form_terms.sql
-- Controlled-document metadata and terms for each scheme's application form.
--
-- Each scheme's registration form is a controlled government document with its
-- own control number and version, and carries a terms-and-conditions agreement
-- (and, for TB, a confidentiality waiver). The control number + version live on
-- the scheme; what the lab agreed to is snapshotted onto the laboratory row at
-- submission, so there is a record of exactly which document version was signed.

-- ---- the scheme's form definition ----
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS form_control_number VARCHAR;
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS form_version VARCHAR;
-- the authority named in the agreement sentence ("...as provided by <X>")
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS form_terms_authority VARCHAR;
-- TB asks the lab whether it waives confidentiality; the others do not
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS requires_confidentiality_waiver BOOLEAN NOT NULL DEFAULT FALSE;

-- seed the known forms (matched on name so a re-run is harmless). Version is
-- not stated on the source documents - seeded as 1.0, update when known.
UPDATE schemes SET
    form_control_number = 'CDL-PT-F-002',
    form_version = COALESCE(form_version, '1.0'),
    form_terms_authority = 'CDL',
    requires_confidentiality_waiver = TRUE
WHERE name ILIKE 'Tuberculosis%';

UPDATE schemes SET
    form_control_number = 'MF-NHRTI-006',
    form_version = COALESCE(form_version, '1.0'),
    form_terms_authority = 'NHRTI PT SERVICES',
    requires_confidentiality_waiver = FALSE
WHERE name ILIKE 'Bacteriology%';

-- the Virology PT form (LMUTHL-MF-006) covers both HIV-1 Viral Load and HIV EID
UPDATE schemes SET
    form_control_number = 'LMUTHL-MF-006',
    form_version = COALESCE(form_version, '1.0'),
    form_terms_authority = 'Virology PT',
    requires_confidentiality_waiver = FALSE
WHERE name ILIKE 'HIV-1 Viral Load%' OR name ILIKE 'HIV EID%';

-- ---- what a lab agreed to, captured at submission ----
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS form_control_number VARCHAR;
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS form_version VARCHAR;
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS terms_accepted BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS terms_accepted_at TIMESTAMPTZ;
-- null when the scheme does not ask; TRUE = waives confidentiality, FALSE = keeps it
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS confidentiality_waiver BOOLEAN;
