-- 012_facilities.sql
-- Master Facility List (MFL) for Zambia.
--
-- Imported from the MoH MFL export (mfl_facilities_export*.xlsx, 3,791 rows).
-- A self-registering user in Zambia picks their facility from this list; a user
-- outside Zambia types a facility name free-hand (see users.facility_name).
--
-- The province/district are kept both as the MFL text and, where the name
-- resolves against the seeded reference tables, as a foreign key - so a lab
-- registered off a facility can inherit the same province_id / district_id the
-- rest of the system filters on.

CREATE TABLE IF NOT EXISTS facilities (
    id                  SERIAL PRIMARY KEY,

    -- identifiers from the MFL
    mfl_code            INTEGER,
    dhis2_uid           VARCHAR,
    hims_code           VARCHAR,

    name                VARCHAR NOT NULL,

    -- location as the MFL states it (text), plus resolved reference keys
    province_name       VARCHAR,
    district_name       VARCHAR,
    province_id         INTEGER REFERENCES provinces(id),
    district_id         INTEGER REFERENCES districts(id),
    constituency        VARCHAR,
    ward                VARCHAR,
    zone                VARCHAR,
    location            VARCHAR,

    -- classification
    type                VARCHAR,
    ownership           VARCHAR,
    ownership_type      VARCHAR,
    operational_status  VARCHAR,

    latitude            DOUBLE PRECISION,
    longitude           DOUBLE PRECISION,

    created_at          TIMESTAMPTZ DEFAULT now()
);

-- the picker searches by name within a province, so index both
CREATE INDEX IF NOT EXISTS ix_facilities_name ON facilities (lower(name));
CREATE INDEX IF NOT EXISTS ix_facilities_province_id ON facilities (province_id);
CREATE INDEX IF NOT EXISTS ix_facilities_mfl_code ON facilities (mfl_code);
