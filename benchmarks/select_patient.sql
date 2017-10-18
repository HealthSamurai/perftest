\set aid random(1, 10000 * :scale)

BEGIN;
SELECT * FROM patient WHERE id = :aid;
-- SELECT * FROM observation LIMIT 1;
-- SELECT resource#>>'{subject,reference}' FROM observation LIMIT 1 OFFSET :aid;
-- select * from patient where id = (select resource#>>'{subject,id}' from observation where id = :aid)::integer;
-- select * from observation where resource @> '{"subject": {"id":' || :aid || '}}'::jsonb;
-- select * from observation where resource @> '{"subject": {"id": :aid}}'::jsonb;
END;
