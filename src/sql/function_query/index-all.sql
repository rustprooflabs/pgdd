SELECT c.oid,
        n.nspname::TEXT AS s_name,
        t.relname::TEXT AS t_name,
        c.relname::TEXT AS i_name,
        i.indnkeyatts AS key_columns,
        i.indnatts AS total_columns,
        i.indisprimary AS primary_key,
        i.indisunique AS unique_index,
        i.indisvalid AS valid_index,
        CASE WHEN i.indpred IS NULL THEN False ELSE True END AS partial_index,
        c.reltuples AS rows_indexed,
        pg_size_pretty(pg_total_relation_size(c.oid::regclass)) AS index_size,
        pg_total_relation_size(c.oid::regclass) AS index_size_bytes,
        CASE
            WHEN n.nspname !~ '^pg_toast'::text
                    AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]))
                THEN false
            ELSE true
        END AS system_object
    FROM pg_catalog.pg_index i
    INNER JOIN pg_catalog.pg_class c
        ON c.relkind = 'i' AND i.indexrelid = c.oid
    INNER JOIN pg_catalog.pg_class t ON i.indrelid = t.oid
    INNER JOIN pg_catalog.pg_namespace t_n ON t_n.oid = t.relnamespace
    INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
;