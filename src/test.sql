WITH s AS (
         SELECT n.oid,
            n.nspname AS s_name,
            pg_get_userbyid(n.nspowner) AS owner,
            ms.data_source,
            ms.sensitive,
            obj_description(n.oid, 'pg_namespace'::name) AS description,
            CASE WHEN n.nspname !~ '^pg_'::text
                    AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]))
                THEN False
                ELSE True
                END AS system_object
           FROM pg_namespace n
             LEFT JOIN dd.meta_schema ms ON n.nspname = ms.s_name
        ),
    f AS (
        SELECT n.nspname AS s_name, COUNT(DISTINCT p.oid) AS function_count
            FROM pg_catalog.pg_proc p
            INNER JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
            GROUP BY n.nspname
        ),
    v AS (
        SELECT n.nspname AS s_name, COUNT(DISTINCT c.oid) AS view_count
            FROM pg_catalog.pg_class c
            INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relkind IN ('v', 'm')
        GROUP BY n.nspname 
        )
 SELECT s.oid, s.s_name::TEXT
   FROM s
     LEFT JOIN pg_class c ON s.oid = c.relnamespace AND (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]))
     LEFT JOIN f ON f.s_name = s.s_name
     LEFT JOIN v ON v.s_name = s.s_name
  GROUP BY s.oid, s.s_name
 ;