-- 015_laboratory_facility.sql
-- Ties a laboratory registration to the facility and the user behind it, and
-- lets one user register for more than one scheme.
--
-- Under the new flow a verified user registers their facility for a scheme, and
-- each scheme registration is its own reviewable laboratory row (so it shows in
-- admin/laboratorys/list with its own per-scheme registration number). The same
-- user - same contact email - may register for several schemes, so the old
-- "one email, one laboratory" unique constraint no longer holds. The lab is now
-- identified by its code; the email is just the contact/owner link.

ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS facility_id INTEGER REFERENCES facilities(id);
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS registered_by_user_id INTEGER REFERENCES users(id);

-- drop the unique email constraint if it is still there
ALTER TABLE laboratorys DROP CONSTRAINT IF EXISTS uq_laboratorys_email_address;

CREATE INDEX IF NOT EXISTS ix_laboratorys_facility_id ON laboratorys (facility_id);
