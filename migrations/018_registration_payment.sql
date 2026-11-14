-- 018_registration_payment.sql
-- Optional payment step in the laboratory registration approval workflow.
--
-- When an approver approves a submitted registration they may mark that payment
-- is required. The registration then goes back to the applicant to attach proof
-- of payment, and returns for a final approval that the Finance role may also
-- perform. If payment is not required (the default) the approval completes in
-- one step as before.
--
-- Local vs international is decided by whether the lab was registered against a
-- Zambian MFL facility: a facility_id means local (ZMW, bank + mobile money);
-- no facility_id (an international facility typed by hand) means USD.

-- ---- per-scheme payment configuration (set by administrators) ----
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS registration_fee_usd NUMERIC(12,2);
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS registration_fee_zmw NUMERIC(12,2);
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS bank_account_details VARCHAR;      -- shown to all applicants
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS mobile_money_details VARCHAR;      -- local applicants only
ALTER TABLE schemes ADD COLUMN IF NOT EXISTS payment_instructions VARCHAR;

-- ---- payment state carried on the registration ----
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS payment_required BOOLEAN NOT NULL DEFAULT FALSE;
-- snapshot of what was due, resolved at the moment payment was required
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS payment_currency VARCHAR;      -- 'USD' or 'ZMW'
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS payment_amount NUMERIC(12,2);
-- proof of payment, attached by the applicant
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS payment_proof_attachment_id INTEGER REFERENCES attachments(id);
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS payment_reference VARCHAR;
ALTER TABLE laboratorys ADD COLUMN IF NOT EXISTS payment_submitted_at TIMESTAMPTZ;

-- ---- two new workflow stages ----
INSERT INTO list_stages (id, stage_name, created_by)
SELECT 6, 'Awaiting Payment', 'migration-018'
WHERE NOT EXISTS (SELECT 1 FROM list_stages WHERE id = 6);
INSERT INTO list_stages (id, stage_name, created_by)
SELECT 7, 'Payment Review', 'migration-018'
WHERE NOT EXISTS (SELECT 1 FROM list_stages WHERE id = 7);

-- keep the sequence ahead of the hand-set ids
SELECT setval(pg_get_serial_sequence('list_stages', 'id'),
              GREATEST((SELECT MAX(id) FROM list_stages), 7));
