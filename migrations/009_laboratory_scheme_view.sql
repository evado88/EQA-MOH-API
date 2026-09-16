-- Which schemes a laboratory is registered in.
--
-- The answer already exists, spread across the applications table: a lab is in
-- a scheme because it applied for one of that scheme's methods and was
-- accepted. Every page that wants to say so was going to have to re-derive
-- that join, and they would not all have agreed on what "registered" means -
-- one would count a pending application, the next would not.
--
-- So it is written down once, here. One row per laboratory per scheme, with
-- the methods behind it and a single word for where the application stands.
--
--   psql -U postgres -d moheqa -f migrations/009_laboratory_scheme_view.sql

DROP VIEW IF EXISTS vw_laboratory_scheme;
CREATE VIEW vw_laboratory_scheme AS
SELECT
    a.lab_id,
    l.code                              AS lab_code,
    l.name                              AS lab_name,
    s.id                                AS scheme_id,
    s.name                              AS scheme_name,
    p.id                                AS provider_id,
    p.name                              AS provider_name,

    count(*)                            AS method_count,
    -- list_statuses: 2 submitted, 3 under review, 4 approved, 5 rejected
    count(*) FILTER (WHERE a.status_id = 4)         AS accepted_count,
    count(*) FILTER (WHERE a.status_id IN (2, 3))   AS pending_count,
    count(*) FILTER (WHERE a.status_id = 5)         AS rejected_count,

    string_agg(m.name, ', ' ORDER BY m.name)        AS method_names,
    string_agg(m.name, ', ' ORDER BY m.name)
        FILTER (WHERE a.status_id = 4)              AS accepted_method_names,

    -- one word for the whole scheme. A lab accepted for any method of a scheme
    -- is in that scheme, whatever became of the rest.
    CASE
        WHEN count(*) FILTER (WHERE a.status_id = 4) > 0       THEN 'Accepted'
        WHEN count(*) FILTER (WHERE a.status_id IN (2, 3)) > 0 THEN 'Pending'
        ELSE 'Rejected'
    END                                             AS participation
FROM applications a
JOIN laboratorys l ON l.id = a.lab_id
JOIN schemes     s ON s.id = a.scheme_id
JOIN providers   p ON p.id = s.provider_id
JOIN methods     m ON m.id = a.method_id
GROUP BY a.lab_id, l.code, l.name, s.id, s.name, p.id, p.name;
