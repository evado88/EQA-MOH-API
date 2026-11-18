-- CLSI zone-diameter breakpoints for the organism groups beyond
-- Enterobacterales (migration 028 seeded Enterobacterales).
--
-- Disk diffusion, zone in mm: susceptible_min = S zone >=, resistant_max =
-- R zone <=, the intermediate band is between them. An agent reported 'S only'
-- (no resistant breakpoint by disk) has resistant_max left NULL.
--
-- EVERY row here is seeded verified = false and sourced 'CLSI M100 (reference)'.
-- It is a provisional starting set to be CHECKED AND CORRECTED against the
-- laboratory's current CLSI M100 edition by the MOH team before it is relied on
-- - several of these were revised in recent editions (flagged in notes). They
-- are display only and never affect a score.
--
--   psql -U postgres -d moheqa -f migrations/029_clsi_breakpoints_more_groups.sql

BEGIN;

INSERT INTO clsi_breakpoints
    (organism_group, antibiotic, method, disk_content,
     susceptible_min, resistant_max, sdd_min, sdd_max, source, verified, notes,
     created_at, created_by)
VALUES
    -- ---- Staphylococcus spp. ----
    ('Staphylococcus spp.','CEFOXITIN','disk_diffusion','30 ug',22,21,NULL,NULL,'CLSI M100 (reference)',FALSE,'S. aureus/lugdunensis (mecA surrogate); CoNS use S>=25 R<=24',now(),'migration-029'),
    ('Staphylococcus spp.','PENICILLIN','disk_diffusion','10 units',29,28,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','ERYTHROMYCIN','disk_diffusion','15 ug',23,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','CLINDAMYCIN','disk_diffusion','2 ug',21,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','CIPROFLOXACIN','disk_diffusion','5 ug',21,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','LEVOFLOXACIN','disk_diffusion','5 ug',19,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','GENTAMICIN','disk_diffusion','10 ug',15,12,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','TETRACYCLINE','disk_diffusion','30 ug',19,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','DOXYCYCLINE','disk_diffusion','30 ug',16,12,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','TRIMETHOPRIM-SULFAMETHOXAZOLE','disk_diffusion','1.25/23.75 ug',16,10,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','RIFAMPIN','disk_diffusion','5 ug',20,16,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','CHLORAMPHENICOL','disk_diffusion','30 ug',18,12,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','LINEZOLID','disk_diffusion','30 ug',21,20,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Staphylococcus spp.','NITROFURANTOIN','disk_diffusion','300 ug',17,14,NULL,NULL,'CLSI M100 (reference)',FALSE,'Urine only',now(),'migration-029'),
    -- ---- Enterococcus spp. ----
    ('Enterococcus spp.','AMPICILLIN','disk_diffusion','10 ug',17,16,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Enterococcus spp.','PENICILLIN','disk_diffusion','10 units',15,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Enterococcus spp.','VANCOMYCIN','disk_diffusion','30 ug',17,14,NULL,NULL,'CLSI M100 (reference)',FALSE,'Read at 24h; zone 15-16 needs MIC',now(),'migration-029'),
    ('Enterococcus spp.','CIPROFLOXACIN','disk_diffusion','5 ug',21,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Enterococcus spp.','LEVOFLOXACIN','disk_diffusion','5 ug',17,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Enterococcus spp.','LINEZOLID','disk_diffusion','30 ug',23,20,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Enterococcus spp.','TETRACYCLINE','disk_diffusion','30 ug',19,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Enterococcus spp.','NITROFURANTOIN','disk_diffusion','300 ug',17,14,NULL,NULL,'CLSI M100 (reference)',FALSE,'Urine only',now(),'migration-029'),
    ('Enterococcus spp.','GENTAMICIN','disk_diffusion','120 ug',10,6,NULL,NULL,'CLSI M100 (reference)',FALSE,'High-level synergy screen; zone 7-9 inconclusive',now(),'migration-029'),
    -- ---- Pseudomonas aeruginosa ----
    ('Pseudomonas aeruginosa','PIPERACILLIN-TAZOBACTAM','disk_diffusion','100/10 ug',21,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Pseudomonas aeruginosa','CEFTAZIDIME','disk_diffusion','30 ug',18,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Pseudomonas aeruginosa','CEFEPIME','disk_diffusion','30 ug',18,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Pseudomonas aeruginosa','AZTREONAM','disk_diffusion','30 ug',22,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Pseudomonas aeruginosa','IMIPENEM','disk_diffusion','10 ug',19,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Pseudomonas aeruginosa','MEROPENEM','disk_diffusion','10 ug',19,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Pseudomonas aeruginosa','CIPROFLOXACIN','disk_diffusion','5 ug',25,18,NULL,NULL,'CLSI M100 (reference)',FALSE,'Revised in M100-Ed32 (2022)',now(),'migration-029'),
    ('Pseudomonas aeruginosa','LEVOFLOXACIN','disk_diffusion','5 ug',22,14,NULL,NULL,'CLSI M100 (reference)',FALSE,'Revised in M100-Ed32 (2022)',now(),'migration-029'),
    ('Pseudomonas aeruginosa','TOBRAMYCIN','disk_diffusion','10 ug',15,12,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Pseudomonas aeruginosa','AMIKACIN','disk_diffusion','30 ug',17,14,NULL,NULL,'CLSI M100 (reference)',FALSE,'Aminoglycoside breakpoints revised; verify',now(),'migration-029'),
    ('Pseudomonas aeruginosa','GENTAMICIN','disk_diffusion','10 ug',15,12,NULL,NULL,'CLSI M100 (reference)',FALSE,'Aminoglycoside breakpoints revised; verify',now(),'migration-029'),
    -- ---- Acinetobacter spp. ----
    ('Acinetobacter spp.','AMPICILLIN-SULBACTAM','disk_diffusion','10/10 ug',15,11,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','PIPERACILLIN-TAZOBACTAM','disk_diffusion','100/10 ug',21,17,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','CEFTAZIDIME','disk_diffusion','30 ug',18,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','CEFEPIME','disk_diffusion','30 ug',18,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','IMIPENEM','disk_diffusion','10 ug',22,18,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','MEROPENEM','disk_diffusion','10 ug',18,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','CIPROFLOXACIN','disk_diffusion','5 ug',21,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','LEVOFLOXACIN','disk_diffusion','5 ug',17,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','GENTAMICIN','disk_diffusion','10 ug',15,12,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','TOBRAMYCIN','disk_diffusion','10 ug',15,12,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','AMIKACIN','disk_diffusion','30 ug',17,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','TRIMETHOPRIM-SULFAMETHOXAZOLE','disk_diffusion','1.25/23.75 ug',16,10,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','MINOCYCLINE','disk_diffusion','30 ug',16,12,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Acinetobacter spp.','DOXYCYCLINE','disk_diffusion','30 ug',13,9,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    -- ---- Streptococcus pneumoniae ----
    ('Streptococcus pneumoniae','OXACILLIN','disk_diffusion','1 ug',20,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Penicillin screen; <20 mm requires penicillin MIC',now(),'migration-029'),
    ('Streptococcus pneumoniae','ERYTHROMYCIN','disk_diffusion','15 ug',21,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus pneumoniae','CLINDAMYCIN','disk_diffusion','2 ug',19,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus pneumoniae','TETRACYCLINE','disk_diffusion','30 ug',23,18,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus pneumoniae','TRIMETHOPRIM-SULFAMETHOXAZOLE','disk_diffusion','1.25/23.75 ug',19,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus pneumoniae','CHLORAMPHENICOL','disk_diffusion','30 ug',21,20,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus pneumoniae','LEVOFLOXACIN','disk_diffusion','5 ug',17,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus pneumoniae','VANCOMYCIN','disk_diffusion','30 ug',17,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Susceptible only',now(),'migration-029'),
    ('Streptococcus pneumoniae','LINEZOLID','disk_diffusion','30 ug',21,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Susceptible only',now(),'migration-029'),
    -- ---- Streptococcus spp. (beta-hemolytic) ----
    ('Streptococcus spp.','PENICILLIN','disk_diffusion','10 units',24,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Groups A/B/C/G generally susceptible',now(),'migration-029'),
    ('Streptococcus spp.','ERYTHROMYCIN','disk_diffusion','15 ug',21,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus spp.','CLINDAMYCIN','disk_diffusion','2 ug',19,15,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus spp.','TETRACYCLINE','disk_diffusion','30 ug',23,18,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus spp.','LEVOFLOXACIN','disk_diffusion','5 ug',17,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Streptococcus spp.','VANCOMYCIN','disk_diffusion','30 ug',17,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Susceptible only',now(),'migration-029'),
    ('Streptococcus spp.','CHLORAMPHENICOL','disk_diffusion','30 ug',21,17,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    -- ---- Haemophilus spp. ----
    ('Haemophilus spp.','AMPICILLIN','disk_diffusion','10 ug',22,18,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Haemophilus spp.','AMOXICILLIN-CLAVULANATE','disk_diffusion','20/10 ug',20,19,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Haemophilus spp.','CEFTRIAXONE','disk_diffusion','30 ug',26,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Susceptible only',now(),'migration-029'),
    ('Haemophilus spp.','CEFUROXIME','disk_diffusion','30 ug',20,16,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Haemophilus spp.','CIPROFLOXACIN','disk_diffusion','5 ug',21,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Susceptible only',now(),'migration-029'),
    ('Haemophilus spp.','TRIMETHOPRIM-SULFAMETHOXAZOLE','disk_diffusion','1.25/23.75 ug',16,10,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Haemophilus spp.','CHLORAMPHENICOL','disk_diffusion','30 ug',29,25,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Haemophilus spp.','TETRACYCLINE','disk_diffusion','30 ug',29,25,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Haemophilus spp.','AZITHROMYCIN','disk_diffusion','15 ug',12,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Susceptible only',now(),'migration-029'),
    -- ---- Neisseria gonorrhoeae ----
    ('Neisseria gonorrhoeae','PENICILLIN','disk_diffusion','10 units',47,26,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Neisseria gonorrhoeae','CEFTRIAXONE','disk_diffusion','30 ug',35,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Susceptible only',now(),'migration-029'),
    ('Neisseria gonorrhoeae','CEFIXIME','disk_diffusion','5 ug',31,NULL,NULL,NULL,'CLSI M100 (reference)',FALSE,'Susceptible only',now(),'migration-029'),
    ('Neisseria gonorrhoeae','CIPROFLOXACIN','disk_diffusion','5 ug',41,27,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Neisseria gonorrhoeae','TETRACYCLINE','disk_diffusion','30 ug',38,30,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Neisseria gonorrhoeae','SPECTINOMYCIN','disk_diffusion','100 ug',18,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    -- ---- Stenotrophomonas maltophilia ----
    ('Stenotrophomonas maltophilia','TRIMETHOPRIM-SULFAMETHOXAZOLE','disk_diffusion','1.25/23.75 ug',16,10,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Stenotrophomonas maltophilia','LEVOFLOXACIN','disk_diffusion','5 ug',17,13,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Stenotrophomonas maltophilia','MINOCYCLINE','disk_diffusion','30 ug',19,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029'),
    ('Stenotrophomonas maltophilia','CEFTAZIDIME','disk_diffusion','30 ug',18,14,NULL,NULL,'CLSI M100 (reference)',FALSE,NULL,now(),'migration-029')
ON CONFLICT ON CONSTRAINT uq_clsi_breakpoints_group_antibiotic_method DO NOTHING;

COMMIT;
