\set patient_id random(1, 1 * :scale)

BEGIN;
select * from observation where resource @> '{"subject": {"id": :patient_id}}'::jsonb;
END;
