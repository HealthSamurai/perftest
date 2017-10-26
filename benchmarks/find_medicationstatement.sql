\set patient_id random(1, 1 * :scale)

BEGIN;
SELECT * FROM medicationstatement WHERE resource @> '{"subject": {"id": :patient_id}}'::jsonb LIMIT 20;
END;
