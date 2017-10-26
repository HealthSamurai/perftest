\set last_name_id random(1, 88000)

BEGIN;
SELECT * FROM patient WHERE string_join(knife_extract_text(resource, '[["name","given"], ["name","family"]]')) ilike '%' || (SELECT last_name from last_names where id = :last_name_id) || '%' LIMIT 20;
END;
