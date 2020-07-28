
DROP VIEW dd."columns";
CREATE VIEW dd."columns" AS
SELECT n.nspname AS s_name,
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
    a.attnotnull,
    (SELECT pg_catalog.pg_get_expr(d.adbin, d.adrelid, true) AS default_expression
        FROM pg_catalog.pg_attrdef d
        WHERE d.adrelid = a.attrelid
            AND d.adnum = a.attnum
            AND a.atthasdef),
    CASE WHEN a.attgenerated = '' THEN False 
        ELSE True 
        END AS generated_column
   FROM pg_attribute a
     JOIN pg_class c ON a.attrelid = c.oid
     JOIN pg_namespace n ON n.oid = c.relnamespace
     JOIN pg_type t ON a.atttypid = t.oid
     LEFT JOIN dd.meta_column mc ON n.nspname = mc.s_name AND c.relname = mc.t_name AND a.attname = mc.c_name
  WHERE (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])) AND n.nspname !~ '^pg_toast'::text AND a.attnum > 0 AND (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char", 's'::"char", 'v'::"char", 'f'::"char", 'm'::"char"]))
;


COMMENT ON VIEW dd.columns IS 'Data dictionary view:  Lists columns in tables';
COMMENT ON COLUMN dd.columns.system_object IS 'Allows to easily show/hide system objects.';
