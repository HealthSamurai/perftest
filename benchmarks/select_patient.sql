\set patient_id random(1, 1 * :scale)

BEGIN;
SELECT * FROM patient WHERE id = ':patient_id' LIMIT 20;
END;
