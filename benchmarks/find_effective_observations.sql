\set patient_id random(1, 1 * :scale)
\set year_start random(2012, 2013)
\set year_end random(2014, 2015)
\set month random(1,9)

BEGIN;
-- no need in indexes on effective period there, subject id has high enough cardinality
SELECT * FROM observation WHERE (knife_extract_min_timestamptz(observation.resource, '[["effective", "period", "end"]]') < knife_date_bound(':year_end-0:month-27', 'min') AND knife_extract_max_timestamptz(observation.resource, '[["effective", "period", "start"]]') > knife_date_bound(':year_start-0:month-01', 'max') AND knife_extract_text(observation.resource, '[["subject", "id"]]') = ARRAY[':patient_id']) LIMIT 20;
-- AND resource @> '{"subject": {"id": :aid}}'::jsonb); -- MUCH FASTER
END;
