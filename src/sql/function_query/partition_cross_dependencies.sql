/*
    Both final partition views have cross dependencies on their _all views.
    Putting both in this script to make those dependencies clear.

    Could probably be refactored, but not a high priority.
*/

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
    FROM dd.partition_parents_all p
    LEFT JOIN dd.partition_child_all c ON p.oid = c.parent_oid
    LEFT JOIN dd.tables_all t ON c.oid = t.oid
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
    FROM dd.partition_child_all pc
    INNER JOIN dd.partition_parents pp ON pc.parent_oid = pp.oid
    INNER JOIN dd.tables_all t ON pc.oid = t.oid
;
