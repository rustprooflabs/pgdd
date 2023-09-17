CREATE OR REPLACE VIEW dd.schemas AS
SELECT * FROM dd.schemas()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.tables AS
SELECT * FROM dd.tables()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.views AS
SELECT * FROM dd.views()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.columns AS
SELECT * FROM dd.columns()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.functions AS
SELECT * FROM dd.functions()
    WHERE NOT system_object
;


CREATE OR REPLACE VIEW dd.partition_parents AS
WITH partition_details AS (
SELECT p.oid, p.s_name, p.t_name, p.partition_type, p.partitions,
        SUM(t.size_bytes) AS size_bytes,
        -- Check for Postgres 14 and newer
        -- "If the table has never yet been vacuumed or analyzed, reltuples contains -1 indicating that the row count is unknown."
        -- https://www.postgresql.org/docs/current/catalog-pg-class.html
        SUM(CASE WHEN t.rows = -1 THEN NULL ELSE t.rows END) AS rows,
        COUNT(*) FILTER (WHERE t.rows = -1) AS partitions_never_analyzed,
        COUNT(*) FILTER (WHERE t.rows = 0) AS partitions_no_data
    FROM dd.partition_parents() p
    LEFT JOIN dd.partition_children() c ON p.oid = c.parent_oid
    LEFT JOIN dd.tables() t ON c.oid = t.oid
    GROUP BY p.oid, p.s_name, p.t_name, p.partition_type, p.partitions
)
SELECT oid, s_name, t_name, partition_type, partitions,
        size_bytes, pg_size_pretty(size_bytes) AS size_pretty,
        CASE WHEN partitions > 0
            THEN pg_size_pretty(ROUND(size_bytes / partitions))
            ELSE NULL
        END AS size_per_partition,
        rows,
        CASE WHEN partitions > 0
            THEN ROUND(rows / partitions)
            ELSE NULL
        END AS rows_per_partition,
        partitions_never_analyzed,
        partitions_no_data
    FROM partition_details
;


CREATE OR REPLACE VIEW dd.partition_children AS
SELECT pc.oid, pc.s_name, pc.t_name, pc.parent_oid, pc.parent_name,
        t.rows, t.size_bytes, t.size_pretty, t.size_plus_indexes, t.bytes_per_row,
        CASE WHEN pp.rows > 0
            THEN ROUND(t.rows * 1.0 / pp.rows, 4)
            ELSE NULL
            END AS percent_of_partition_rows,
        CASE WHEN pp.size_bytes > 0
            THEN ROUND(t.size_bytes * 1.0 / pp.size_bytes, 4)
            ELSE NULL
            END AS percent_of_partition_bytes
    FROM dd.partition_children() pc
    INNER JOIN dd.partition_parents pp ON pc.parent_oid = pp.oid
    INNER JOIN dd.tables() t ON pc.oid = t.oid
;


CREATE OR REPLACE VIEW dd.database AS
SELECT *
    FROM dd.database()
;

CREATE OR REPLACE VIEW dd.index AS
SELECT * FROM dd.index()
    WHERE NOT system_object
;
