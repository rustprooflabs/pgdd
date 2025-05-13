CREATE VIEW dd.schemas_all AS
WITH s AS (
     SELECT n.oid,
        n.nspname AS s_name,
        pg_get_userbyid(n.nspowner) AS owner,
        ms.data_source,
        ms.sensitive,
        obj_description(n.oid, 'pg_namespace'::name) AS description,
            CASE
                WHEN n.nspname !~ '^pg_'::text AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])) THEN false
                ELSE true
            END AS system_object
       FROM pg_namespace n
         LEFT JOIN dd.meta_schema ms ON n.nspname = ms.s_name
    ), f AS (
    SELECT n.nspname AS s_name,
            count(DISTINCT p.oid) AS function_count
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        GROUP BY n.nspname
    ), v AS (
    SELECT n.nspname AS s_name,
        count(DISTINCT c_1.oid) AS view_count
        FROM pg_class c_1
        JOIN pg_namespace n ON n.oid = c_1.relnamespace
        WHERE c_1.relkind = ANY (ARRAY['v'::"char", 'm'::"char"])
        GROUP BY n.nspname
    )
SELECT s.s_name::TEXT,
        s.owner::TEXT,
        s.data_source::TEXT,
        s.sensitive::BOOLEAN,
        s.description::TEXT,
        s.system_object,
        COALESCE(count(c.*), 0::bigint)::BIGINT AS table_count,
        COALESCE(v.view_count, 0::bigint)::BIGINT AS view_count,
        COALESCE(f.function_count, 0::bigint)::BIGINT AS function_count,
        pg_size_pretty(sum(pg_table_size(c.oid::regclass)))::TEXT AS size_pretty,
        pg_size_pretty(sum(pg_total_relation_size(c.oid::regclass)))::TEXT AS size_plus_indexes,
        sum(pg_table_size(c.oid::regclass))::BIGINT AS size_bytes,
        sum(pg_total_relation_size(c.oid::regclass))::BIGINT AS size_plus_indexes_bytes
    FROM s
    LEFT JOIN pg_class c
        ON s.oid = c.relnamespace
            AND (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]))
    LEFT JOIN f ON f.s_name = s.s_name
    LEFT JOIN v ON v.s_name = s.s_name
    GROUP BY s.s_name, s.owner, s.data_source, s.sensitive,
        s.description, s.system_object, v.view_count,
        f.function_count
;


CREATE OR REPLACE VIEW dd.schemas AS
SELECT * FROM dd.schemas_all
    WHERE NOT system_object
;



COMMENT ON VIEW dd.schemas_all IS 'Data dictionary view: Lists all schemas, including system schemas';
COMMENT ON VIEW dd.schemas IS 'Data dictionary view: Lists schemas, excluding system schemas.';
