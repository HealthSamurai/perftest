\set aid random(1, 10000 * :scale)

BEGIN;
select * from medicationstatement where resource @> '{"subject": {"id": :aid}}'::jsonb;
END;
