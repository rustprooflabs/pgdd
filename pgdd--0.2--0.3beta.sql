
-- dd."schemas" source

DROP VIEW dd."schemas";

CREATE VIEW dd."schemas"
AS WITH s AS (
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
        )
 SELECT s.s_name,
    s.owner,
    s.data_source,
    s.sensitive,
    s.description,
    s.system_object,
    COALESCE(count(c.*), 0::bigint)::integer AS table_count,
    pg_size_pretty(sum(pg_table_size(c.oid::regclass))) AS size_pretty,
    pg_size_pretty(sum(pg_total_relation_size(c.oid::regclass))) AS size_plus_indexes,
    sum(pg_table_size(c.oid::regclass)) AS size_bytes
   FROM s
     LEFT JOIN pg_class c ON s.oid = c.relnamespace AND (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]))
  GROUP BY s.s_name, s.owner, s.data_source,
        s.sensitive, s.description, s.system_object
 ;



DROP VIEW dd."tables";
CREATE VIEW dd."tables"
AS SELECT n.nspname AS s_name,
    c.relname AS t_name,
        CASE
            WHEN c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]) THEN 'table'::text
            WHEN c.relkind = 's'::"char" THEN 'special'::text
            WHEN c.relkind = 'f'::"char" THEN 'foreign table'::text
            ELSE NULL::text
        END AS type,
    pg_get_userbyid(c.relowner) AS owner,
    pg_size_pretty(pg_table_size(c.oid::regclass)) AS size_pretty,
    pg_table_size(c.oid::regclass) AS size_bytes,
    c.reltuples AS rows,
        CASE
            WHEN c.reltuples > 0::double precision THEN pg_table_size(c.oid::regclass)::double precision / c.reltuples
            ELSE NULL::double precision
        END AS bytes_per_row,
    pg_size_pretty(pg_total_relation_size(c.oid::regclass)) AS size_plus_indexes,
    obj_description(c.oid, 'pg_class'::name) AS description,
    CASE WHEN n.nspname !~ '^pg_toast'::text AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]))
        THEN False
        ELSE True
        END AS system_object,
    mt.data_source,
    mt.sensitive
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN dd.meta_table mt ON n.nspname = mt.s_name AND c.relname = mt.t_name
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char", 's'::"char", 'f'::"char"]))
;


-- dd."views" source
DROP VIEW dd."views";
CREATE VIEW dd."views"
AS SELECT n.nspname AS s_name,
    c.relname AS v_name,
        CASE c.relkind
            WHEN 'v'::"char" THEN 'view'::text
            WHEN 'm'::"char" THEN 'materialized view'::text
            ELSE NULL::text
        END AS view_type,
    pg_get_userbyid(c.relowner) AS owner,
    c.reltuples AS rows,
    pg_size_pretty(pg_table_size(c.oid::regclass)) AS size_pretty,
    pg_table_size(c.oid::regclass) AS size_bytes,
    obj_description(c.oid, 'pg_class'::name) AS description,
    CASE WHEN n.nspname !~ '^pg_toast'::text AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]))
        THEN False
        ELSE True
        END AS system_object
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE (c.relkind = ANY (ARRAY['v'::"char", 'm'::"char"])) AND n.nspname !~ '^pg_toast'::text;



DROP VIEW dd."columns";
CREATE VIEW dd."columns"
AS SELECT n.nspname AS s_name,
        CASE c.relkind
            WHEN 'r'::"char" THEN 'table'::text
            WHEN 'v'::"char" THEN 'view'::text
            WHEN 'm'::"char" THEN 'materialized view'::text
            WHEN 's'::"char" THEN 'special'::text
            WHEN 'f'::"char" THEN 'foreign table'::text
            WHEN 'p'::"char" THEN 'table'::text
            ELSE NULL::text
        END AS type,
    c.relname AS t_name,
    a.attname AS column_name,
    t.typname AS data_type,
    a.attnum AS "position",
    col_description(c.oid, a.attnum::integer) AS description,
    mc.data_source,
    mc.sensitive,
    CASE WHEN (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])) AND n.nspname !~ '^pg_toast'::text
        THEN False
        ELSE True
        END AS system_object
   FROM pg_attribute a
     JOIN pg_class c ON a.attrelid = c.oid
     JOIN pg_namespace n ON n.oid = c.relnamespace
     JOIN pg_type t ON a.atttypid = t.oid
     LEFT JOIN dd.meta_column mc ON n.nspname = mc.s_name AND c.relname = mc.t_name AND a.attname = mc.c_name
  WHERE a.attnum > 0 AND (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char", 's'::"char", 'v'::"char", 'f'::"char", 'm'::"char"]))
;



DROP VIEW dd."functions";
CREATE VIEW dd."functions"
AS SELECT n.nspname AS s_name,
    p.proname AS f_name,
    pg_get_function_result(p.oid) AS result_data_types,
    pg_get_function_arguments(p.oid) AS argument_data_types,
    pg_get_userbyid(p.proowner) AS "Owner",
        CASE
            WHEN p.prosecdef THEN 'definer'::text
            ELSE 'invoker'::text
        END AS proc_security,
    array_to_string(p.proacl, ''::text) AS access_privileges,
    l.lanname AS proc_language,
    p.prosrc AS source_code,
    obj_description(p.oid, 'pg_proc'::name) AS description,
    CASE WHEN n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])
        THEN False
        ELSE True
        END AS system_object
   FROM pg_proc p
     LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
     LEFT JOIN pg_language l ON l.oid = p.prolang
;


COMMENT ON VIEW dd.schemas IS 'Data dictionary view:  Lists schemas';
COMMENT ON VIEW dd.tables IS 'Data dictionary view:  Lists tables';
COMMENT ON VIEW dd.views IS 'Data dictionary view:  Lists views and materialized views';
COMMENT ON VIEW dd.functions IS 'Data dictionary view:  Lists functions (procedures)';
COMMENT ON VIEW dd.columns IS 'Data dictionary view:  Lists columns in tables';

COMMENT ON COLUMN dd.schemas.size_plus_indexes IS 'Total size (pretty) of data, TOAST, and indexes.  Suitable for display';
COMMENT ON COLUMN dd.schemas.size_pretty IS 'Size (pretty) of data and TOAST.  Does not include indexes. Suitable for display';
COMMENT ON COLUMN dd.schemas.size_bytes IS 'Size (bytes) of data and TOAST.  Does not include indexes. Suitable for sorting. ';

COMMENT ON COLUMN dd.tables.size_plus_indexes IS 'Total size (pretty) of data, TOAST, and indexes.  Suitable for display';
COMMENT ON COLUMN dd.tables.size_pretty IS 'Size (pretty) of data and TOAST.  Does not include indexes. Suitable for display';
COMMENT ON COLUMN dd.tables.size_bytes IS 'Size (bytes) of data and TOAST.  Does not include indexes. Suitable for sorting. ';

COMMENT ON COLUMN dd.schemas.system_object IS 'Allows to easily show/hide system objects.';
COMMENT ON COLUMN dd.tables.system_object IS 'Allows to easily show/hide system objects.';
COMMENT ON COLUMN dd.views.system_object IS 'Allows to easily show/hide system objects.';
COMMENT ON COLUMN dd.functions.system_object IS 'Allows to easily show/hide system objects.';
COMMENT ON COLUMN dd.columns.system_object IS 'Allows to easily show/hide system objects.';

