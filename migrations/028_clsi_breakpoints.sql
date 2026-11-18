-- CLSI zone-diameter breakpoints, for the AST report's expected-range column.
--
-- The scheme scores AST on the interpretation a laboratory reports, not on the
-- millimetres (see helpers/evaluation._grade_ast). These are reference only:
-- they let the feedback report print the expected zone-diameter range beside
-- each antibiotic, as the paper form TF-NHRTI-BACT-008 does.
--
-- CLSI M100 revises these every year and they are organism-group specific, so
-- they live in a table rather than in code, carry a source, and are seeded
-- 'verified = false': the set below is a provisional starting point for
-- Enterobacterales disk diffusion and MUST be checked against the laboratory's
-- current CLSI M100 edition before it is relied on. The aminoglycoside and
-- fluoroquinolone breakpoints in particular were revised in recent editions.
--
--   psql -U postgres -d moheqa -f migrations/028_clsi_breakpoints.sql

BEGIN;

CREATE TABLE IF NOT EXISTS clsi_breakpoints (
    id               SERIAL PRIMARY KEY,
    organism_group   VARCHAR NOT NULL,
    antibiotic       VARCHAR NOT NULL,
    method           VARCHAR NOT NULL DEFAULT 'disk_diffusion',
    disk_content     VARCHAR,
    susceptible_min  INTEGER,
    resistant_max    INTEGER,
    sdd_min          INTEGER,
    sdd_max          INTEGER,
    source           VARCHAR,
    verified         BOOLEAN NOT NULL DEFAULT FALSE,
    notes            VARCHAR,
    created_at       TIMESTAMPTZ,
    created_by       VARCHAR,
    updated_at       TIMESTAMPTZ,
    updated_by       VARCHAR
);

DO $$ BEGIN
    ALTER TABLE clsi_breakpoints
        ADD CONSTRAINT uq_clsi_breakpoints_group_antibiotic_method
        UNIQUE (organism_group, antibiotic, method);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS ix_clsi_breakpoints_group
    ON clsi_breakpoints (organism_group);

-- Enterobacterales, disk diffusion. susceptible_min = S zone >=, resistant_max
-- = R zone <=, the intermediate band is between them. Seeded provisional.
INSERT INTO clsi_breakpoints
    (organism_group, antibiotic, method, disk_content,
     susceptible_min, resistant_max, sdd_min, sdd_max, source, verified, notes,
     created_at, created_by)
VALUES
    ('Enterobacterales','AMPICILLIN','disk_diffusion','10 ug',17,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','AMOXICILLIN-CLAVULANATE','disk_diffusion','20/10 ug',18,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','AMPICILLIN-SULBACTAM','disk_diffusion','10/10 ug',15,11,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','PIPERACILLIN-TAZOBACTAM','disk_diffusion','100/10 ug',21,17,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','CEFAZOLIN','disk_diffusion','30 ug',15,12,NULL,NULL,'CLSI M100 (reference)',FALSE,'Uncomplicated UTI surrogate',now(),'migration-028'),
    ('Enterobacterales','CEFOTAXIME','disk_diffusion','30 ug',26,22,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','CEFTRIAXONE','disk_diffusion','30 ug',23,19,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','CEFTAZIDIME','disk_diffusion','30 ug',21,17,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','CEFEPIME','disk_diffusion','30 ug',25,18,19,24,'CLSI M100 (reference)',FALSE,'SDD band 19-24 mm',now(),'migration-028'),
    ('Enterobacterales','CEFOXITIN','disk_diffusion','30 ug',18,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','AZTREONAM','disk_diffusion','30 ug',21,17,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','ERTAPENEM','disk_diffusion','10 ug',22,18,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','IMIPENEM','disk_diffusion','10 ug',23,19,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','MEROPENEM','disk_diffusion','10 ug',23,19,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','CIPROFLOXACIN','disk_diffusion','5 ug',26,21,NULL,NULL,'CLSI M100 (reference)',FALSE,'Revised in M100-Ed29 (2019)',now(),'migration-028'),
    ('Enterobacterales','LEVOFLOXACIN','disk_diffusion','5 ug',21,16,NULL,NULL,'CLSI M100 (reference)',FALSE,'Revised in M100-Ed29 (2019)',now(),'migration-028'),
    ('Enterobacterales','NALIDIXIC ACID','disk_diffusion','30 ug',19,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','GENTAMICIN','disk_diffusion','10 ug',15,12,NULL,NULL,'CLSI M100 (reference)',FALSE,'Aminoglycoside breakpoints revised in M100-Ed32 (2022); verify',now(),'migration-028'),
    ('Enterobacterales','TOBRAMYCIN','disk_diffusion','10 ug',15,12,NULL,NULL,'CLSI M100 (reference)',FALSE,'Aminoglycoside breakpoints revised in M100-Ed32 (2022); verify',now(),'migration-028'),
    ('Enterobacterales','AMIKACIN','disk_diffusion','30 ug',17,14,NULL,NULL,'CLSI M100 (reference)',FALSE,'Aminoglycoside breakpoints revised in M100-Ed32 (2022); verify',now(),'migration-028'),
    ('Enterobacterales','TETRACYCLINE','disk_diffusion','30 ug',15,11,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','DOXYCYCLINE','disk_diffusion','30 ug',14,10,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','CHLORAMPHENICOL','disk_diffusion','30 ug',18,12,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','TRIMETHOPRIM-SULFAMETHOXAZOLE','disk_diffusion','1.25/23.75 ug',16,10,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-028'),
    ('Enterobacterales','NITROFURANTOIN','disk_diffusion','300 ug',17,14,NULL,NULL,'CLSI M100 (reference)',FALSE,'Urine only',now(),'migration-028')
ON CONFLICT ON CONSTRAINT uq_clsi_breakpoints_group_antibiotic_method DO NOTHING;

COMMIT;
