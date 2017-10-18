\set aid random(1, 88000 * :scale)

BEGIN;
SELECT * FROM patient WHERE string_join(knife_extract_text(resource, '[["name","given"], ["name","family"]]')) ilike '%' || (SELECT last_name from last_names where id = :aid) || '%';
END;
