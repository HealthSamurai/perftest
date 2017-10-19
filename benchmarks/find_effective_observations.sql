\set aid random(1, 10000)

BEGIN;
-- no need in indexes on effective period there, subject id has high enough cardinality
SELECT * FROM observation WHERE (knife_extract_min_timestamptz(observation.resource, '[["effective", "period", "end"]]') < knife_date_bound('2015-12-31', 'min') AND knife_extract_max_timestamptz(observation.resource, '[["effective", "period", "start"]]') > knife_date_bound('2012-01-01', 'max') AND knife_extract_text(observation.resource, '[["subject", "id"]]') = ARRAY[':aid']);
-- AND resource @> '{"subject": {"id": :aid}}'::jsonb); -- MUCH FASTER
END;
