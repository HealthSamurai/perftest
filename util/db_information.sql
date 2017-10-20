SELECT name, setting, unit  FROM pg_settings
WHERE name IN (
'max_connections',
'shared_buffer',
'effective_cache_size',
'work_mem',
'maintenance_work_mem',
'min_wal_size',
'max_wal_size',
'checkpoint_completion_target',
'wal_buffer',
'default_statistics_target'
);


SELECT nspname || '.' || relname AS "relation",
pg_size_pretty(pg_relation_size(C.oid)) AS "size"
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_relation_size(C.oid) DESC
LIMIT 10;
