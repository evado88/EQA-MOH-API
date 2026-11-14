-- 014_scheme_registration.sql
-- Per-scheme laboratory registration numbers.
--
-- Each scheme wants its own registration number for the labs it accepts,
-- built from a short scheme code and a running count, e.g. TB-001. The code
-- lives on the scheme; the assigned number lives on the application rows a lab
-- raises when it registers for that scheme (every method application for the
-- same lab+scheme shares the one number).

ALTER TABLE schemes ADD COLUMN IF NOT EXISTS code VARCHAR;

ALTER TABLE applications ADD COLUMN IF NOT EXISTS registration_number VARCHAR;

-- seed the codes for the schemes seeded so far; matched on name so a re-run is
-- harmless. New schemes get a code from the admin scheme form / server default.
UPDATE schemes SET code = 'TB'   WHERE code IS NULL AND name ILIKE 'Tuberculosis%';
UPDATE schemes SET code = 'VL'   WHERE code IS NULL AND name ILIKE 'HIV-1 Viral Load%';
UPDATE schemes SET code = 'EID'  WHERE code IS NULL AND name ILIKE 'HIV EID%';
UPDATE schemes SET code = 'BACT' WHERE code IS NULL AND name ILIKE 'Bacteriology%';

-- a fallback for any remaining scheme: first four letters, upper-cased
UPDATE schemes SET code = upper(left(regexp_replace(name, '[^A-Za-z]', '', 'g'), 4))
WHERE code IS NULL;
