SELECT c.oid::BIGINT,
        ns.nspname::TEXT AS s_name,
        c.relname::TEXT AS t_name,
        i.inhparent::BIGINT AS parent_oid,
        i.inhparent::regclass::TEXT AS parent_name,
        c.relispartition::BOOLEAN AS declarative_partition,
        pg_catalog.pg_get_expr(c.relpartbound, c.oid)::TEXT
            AS partition_expression
FROM pg_catalog.pg_class c
INNER JOIN pg_catalog.pg_namespace ns ON c.relnamespace = ns.oid
INNER JOIN pg_catalog.pg_inherits i ON c.oid = i.inhrelid
INNER JOIN pg_catalog.pg_class cp ON i.inhparent = cp.oid
    WHERE c.relkind IN ('r', 'p')
;