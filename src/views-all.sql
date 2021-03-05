SELECT n.nspname::TEXT AS s_name,
    c.relname::TEXT AS v_name,
        CASE c.relkind
            WHEN 'v'::"char" THEN 'view'::text
            WHEN 'm'::"char" THEN 'materialized view'::text
            ELSE NULL::text
        END AS view_type,
    pg_get_userbyid(c.relowner)::TEXT AS owned_by,
    c.reltuples::BIGINT AS rows,
    pg_size_pretty(pg_table_size(c.oid::regclass))::TEXT AS size_pretty,
    pg_table_size(c.oid::regclass)::BIGINT AS size_bytes,
    obj_description(c.oid, 'pg_class'::name)::TEXT AS description,
    CASE
        WHEN n.nspname !~ '^pg_toast'::text AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]))
            THEN false
        ELSE true
    END AS system_object
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE (c.relkind = ANY (ARRAY['v'::"char", 'm'::"char"]))
;