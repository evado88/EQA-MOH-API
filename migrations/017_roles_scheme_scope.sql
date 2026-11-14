-- 017_roles_scheme_scope.sql
-- Ties the provider scheme-team roles to a single scheme, and adds the
-- Ministry of Health (MOH) role.
--
-- Role model after this migration:
--   1 Administrator ....... system administration, every scheme, all actions
--   2-4 Scheme Head/Coordinator/Quality Officer
--   5-8 Finance/PBs/FPPs/District Lab Coordinator
--        -> roles 2-8 are the "scheme team": each tied to ONE scheme and may
--           not perform system administration (managing users, catalogue, ...)
--   9 Facility Super User .. default self-registration role; may enter/edit
--  10 Facility Staff ....... view-only (management/supervisors), admin-assigned
--  11 Ministry of Health ... every scheme, all operational actions, NO system admin

-- which scheme a provider scheme-team member belongs to (NULL for Administrator,
-- MOH, and facility roles, which are not tied to a single scheme this way)
ALTER TABLE users ADD COLUMN IF NOT EXISTS scheme_id INTEGER REFERENCES schemes(id);
CREATE INDEX IF NOT EXISTS ix_users_scheme_id ON users (scheme_id);

-- add the MOH role if the roles list is seeded and it is not there yet
INSERT INTO roles (name, user_id, status_id, stage_id, approval_levels, created_by)
SELECT 'Ministry of Health (MOH)', 1, 4, 5, 1, 'migration-017'
WHERE EXISTS (SELECT 1 FROM roles)
  AND NOT EXISTS (SELECT 1 FROM roles WHERE name ILIKE 'Ministry of Health%');

-- existing scheme-team accounts (roles 2-8) must now sit under a scheme; default
-- them to TB (the example in the spec) so they keep working. Adjust per user via
-- the admin user form.
UPDATE users
SET scheme_id = (SELECT id FROM schemes WHERE code = 'TB' LIMIT 1)
WHERE role_id BETWEEN 2 AND 8 AND scheme_id IS NULL;
