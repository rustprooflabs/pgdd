WITH partition_child AS (
SELECT c.oid,
        ns.nspname AS s_name,
        c.relname AS t_name,
        i.inhparent AS parent_oid,
        i.inhparent::regclass AS parent_name,
        c.relispartition,
        c.relkind,
        pg_catalog.pg_get_expr(c.relpartbound, c.oid) AS partition_expression
FROM pg_catalog.pg_class c
INNER JOIN pg_catalog.pg_namespace ns ON c.relnamespace = ns.oid
INNER JOIN pg_catalog.pg_inherits i ON c.oid = i.inhrelid
INNER JOIN pg_catalog.pg_class cp ON i.inhparent = cp.oid
    WHERE c.relkind IN ('r', 'p')
)
SELECT *
    FROM partition_child
;