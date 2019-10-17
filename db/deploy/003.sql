-- Deploy pgdd:003 to pg

BEGIN;

	CREATE VIEW dd.views AS
	SELECT n.nspname AS s_name,
	        c.relname AS v_name,
	        CASE c.relkind 
	            WHEN 'v' THEN 'view'
	            WHEN 'm' THEN 'materialized view' 
	            END AS view_type,
	        pg_catalog.pg_get_userbyid(c.relowner) AS owner,
	        c.reltuples AS rows,
	        pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) AS size_pretty,
	        pg_catalog.pg_table_size(c.oid) AS size_bytes,
	        pg_catalog.obj_description(c.oid, 'pg_class') AS description
	    FROM pg_catalog.pg_class c
	    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	    WHERE c.relkind IN ('v', 'm')
	        AND n.nspname !~ '^pg_toast'
	;

	COMMENT ON VIEW dd.views IS 'Data dictionary view:  Lists views and materialized views';

COMMIT;
