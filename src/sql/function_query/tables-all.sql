-- dd."tables" source
SELECT n.nspname::TEXT AS s_name,
    c.relname::TEXT AS t_name,
        CASE
            WHEN c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]) THEN 'table'::text
            WHEN c.relkind = 's'::"char" THEN 'special'::text
            WHEN c.relkind = 'f'::"char" THEN 'foreign table'::text
            ELSE NULL::text
        END AS type,
    pg_get_userbyid(c.relowner)::TEXT AS owned_by,
    pg_size_pretty(pg_table_size(c.oid::regclass))::TEXT AS size_pretty,
    pg_table_size(c.oid::regclass)::BIGINT AS size_bytes,
    c.reltuples::BIGINT AS rows,
        CASE
            WHEN c.reltuples > 0::BIGINT
                THEN (pg_table_size(c.oid::regclass)::double precision / c.reltuples)::BIGINT
            ELSE NULL::BIGINT
        END AS bytes_per_row,
    pg_total_relation_size(c.oid::regclass)::BIGINT AS size_plus_indexes_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid::regclass))::TEXT AS size_plus_indexes,

    obj_description(c.oid, 'pg_class'::name)::TEXT AS description,
        CASE
            WHEN n.nspname !~ '^pg_toast'::text AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])) THEN false
            ELSE true
        END AS system_object,
    mt.data_source,
    mt.sensitive,
    c.oid
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN dd.meta_table mt ON n.nspname = mt.s_name AND c.relname = mt.t_name
  WHERE c.relkind = ANY (ARRAY['r'::"char", 'p'::"char", 's'::"char", 'f'::"char"])
;