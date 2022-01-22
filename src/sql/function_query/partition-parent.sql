-- Declarative is built-in Postgres partitioning per
--     https://www.postgresql.org/docs/current/ddl-partitioning.html
-- Inheritance includes partitions like Timescale hypertables,
--    but probably includes objects that are not partitions such as
--    https://www.postgresql.org/docs/current/tutorial-inheritance.html
WITH partition_parent AS (
SELECT c.oid,
        n.nspname::TEXT AS s_name,
        c.relname::TEXT AS t_name,
        CASE WHEN pt.partrelid IS NOT NULL THEN 'declarative'
            WHEN c.relkind = 'r' THEN 'inheritance'
            ELSE 'unknown' END AS partition_type,
        COUNT(i.inhrelid) AS partitions
    FROM pg_catalog.pg_class c
    INNER JOIN pg_catalog.pg_inherits i ON c.oid = i.inhparent
    LEFT JOIN pg_catalog.pg_partitioned_table pt
        ON c.oid = pt.partrelid 
    LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind != 'I' -- Exclude partitioned indexes
    GROUP BY c.relkind, c.oid, pt.partrelid, n.nspname::TEXT, c.relname::TEXT
)
SELECT *
    FROM partition_parent
;