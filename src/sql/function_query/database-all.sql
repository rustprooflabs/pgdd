WITH db_stats AS (
SELECT d.oid, d.datname AS db_name,
        pg_size_pretty(pg_database_size(d.datname)) AS db_size
    FROM pg_catalog.pg_database d
    WHERE d.datname = current_database()
)
SELECT d.oid::BIGINT, d.db_name::TEXT, d.db_size,
        COUNT(DISTINCT s.s_name) AS schema_count,
        COUNT(DISTINCT t.oid) AS table_count,
        COUNT(DISTINCT e.oid) AS extension_count
    FROM db_stats d
    INNER JOIN dd.tables t ON True
    INNER JOIN dd.schemas s ON True
    INNER JOIN pg_catalog.pg_extension e ON True
    GROUP BY d.oid, d.db_name, d.db_size
;