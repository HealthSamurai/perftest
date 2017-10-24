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

SELECT relation, (jsonb_populate_record(null::json_type, sizes)).* from db_sizes where run = :run limit 10;
