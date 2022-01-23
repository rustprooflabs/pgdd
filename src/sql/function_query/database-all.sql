WITH db_stats AS (
SELECT d.oid, d.datname AS db_name,
        pg_size_pretty(pg_database_size(d.datname)) AS db_size
    FROM pg_catalog.pg_database d
    WHERE d.datname = current_database()
), schema_stats AS (
SELECT COUNT(s.s_name) AS schema_count
    FROM dd.schemas s
), table_stats AS (
SELECT
        COUNT(t.oid) AS table_count,
        pg_size_pretty(SUM(t.size_plus_indexes_bytes)) AS size_in_tables
    FROM dd.tables t
), view_stats AS (
SELECT
        COUNT(v.oid) AS view_count,
        pg_size_pretty(SUM(v.size_plus_indexes_bytes)) AS size_in_views
    FROM dd.views v
), extension_stats AS (
SELECT COUNT(e.oid) AS extension_count
    FROM pg_catalog.pg_extension e
)
SELECT d.oid::BIGINT, d.db_name::TEXT, d.db_size,
        s.schema_count,
        t.table_count, t.size_in_tables,
        v.view_count, v.size_in_views,
        e.extension_count
    FROM db_stats d
    INNER JOIN table_stats t ON True
    INNER JOIN schema_stats s ON True
    INNER JOIN view_stats v ON True
    INNER JOIN extension_stats e ON True
;