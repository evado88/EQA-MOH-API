-- 013_user_self_registration.sql
-- Opens the users table up to public self-registration.
--
-- Until now a user was only ever born from an approved laboratory, so every
-- account already had a password and a laboratory. The new /signup lets a
-- person register themselves first - capturing only country, name, position,
-- phone and email - then prove the email with a verification link that is also
-- where they set their password. Only once that is done may they sign in and
-- go on to register a laboratory for a scheme.
--
-- Consequences for the columns:
--   * password must be nullable - it does not exist until the verify link is used
--   * a self-registered user carries a country and, in Zambia, a facility_id
--     from the MFL; elsewhere a free-typed facility_name
--   * email verification state lives on the row

ALTER TABLE users ALTER COLUMN password DROP NOT NULL;

ALTER TABLE users ADD COLUMN IF NOT EXISTS country           VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS facility_id        INTEGER REFERENCES facilities(id);
ALTER TABLE users ADD COLUMN IF NOT EXISTS facility_name      VARCHAR;

ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified     BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_token VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_sent_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verified_at        TIMESTAMPTZ;

-- the token is looked up on its own when the user follows the link
CREATE INDEX IF NOT EXISTS ix_users_verification_token ON users (verification_token);

-- accounts that predate this migration were all created verified
UPDATE users SET email_verified = TRUE WHERE password IS NOT NULL;
