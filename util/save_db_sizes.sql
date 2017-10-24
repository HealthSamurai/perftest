INSERT INTO db_sizes
       (SELECT nspname || '.' || relname AS "relation",
       json_build_object(:size, pg_relation_size(C.oid)) AS "size",
       :run
       FROM pg_class C
       LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
       WHERE nspname NOT IN ('pg_catalog', 'information_schema')
       ORDER BY pg_relation_size(C.oid) DESC
       LIMIT 20)
ON CONFLICT (relation, run)
DO UPDATE SET sizes = db_sizes.sizes || excluded.sizes;
