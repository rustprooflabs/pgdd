DROP VIEW dd."tables";

CREATE VIEW dd.tables AS
	SELECT n.nspname AS s_name,
		  	c.relname as t_name,
		  	CASE WHEN c.relkind IN ('r', 'p') THEN 'table' 
		  		WHEN c.relkind = 's' THEN 'special'
		  		WHEN c.relkind = 'f' THEN 'foreign table'
		  		END AS type,
		  pg_catalog.pg_get_userbyid(c.relowner) AS owner,
		  pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) AS size_pretty,
		  pg_catalog.pg_table_size(c.oid) AS size_bytes,
		  c.reltuples AS rows,
		  CASE WHEN c.reltuples > 0 
		  	THEN pg_catalog.pg_table_size(c.oid) / c.reltuples
		  	ELSE NULL
		  	END AS bytes_per_row,
		  	pg_catalog.pg_size_pretty(pg_catalog.pg_total_relation_size(c.oid)) AS size_plus_indexes,
		  pg_catalog.obj_description(c.oid, 'pg_class') AS description,
		  mt.data_source, mt.sensitive
		FROM pg_catalog.pg_class c
	    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	    LEFT JOIN dd.meta_table mt ON n.nspname = mt.s_name AND c.relname = mt.t_name
		WHERE c.relkind IN ('r','p','s', 'f')
	      	AND n.nspname !~ '^pg_toast'
	      	AND n.nspname NOT IN ('pg_catalog', 'information_schema')
	;



DROP VIEW dd."schemas";

CREATE VIEW dd.schemas AS 
WITH s AS (
SELECT n.oid, n.nspname AS s_name,
  		pg_catalog.pg_get_userbyid(n.nspowner) AS owner,
  		ms.data_source,
  		ms.sensitive,
  		pg_catalog.obj_description(n.oid, 'pg_namespace') AS description
	FROM pg_catalog.pg_namespace n
	LEFT JOIN dd.meta_schema ms 
		ON n.nspname = ms.s_name
	
	WHERE n.nspname !~ '^pg_' 
		AND n.nspname NOT IN ('pg_catalog', 'information_schema')
)
SELECT s.s_name, s.owner, s.data_source, s.sensitive, 
		s.description,
		COALESCE(COUNT(c.*), 0)::INT AS table_count,
		pg_catalog.pg_size_pretty(SUM(pg_catalog.pg_table_size(c.oid))) AS size_pretty,
		pg_catalog.pg_size_pretty(SUM(pg_catalog.pg_total_relation_size(c.oid))) AS size_plus_indexes,
		SUM(pg_catalog.pg_table_size(c.oid)) AS size_bytes
	FROM s
	LEFT JOIN pg_catalog.pg_class c 
		ON s.oid = c.relnamespace AND c.relkind IN ('r','p')
	GROUP BY s.s_name, s.owner, s.data_source, s.sensitive, s.description
;



COMMENT ON VIEW dd.schemas IS 'Data dictionary view:  Lists schemas';
COMMENT ON VIEW dd.tables IS 'Data dictionary view:  Lists tables';

COMMENT ON COLUMN dd.schemas.size_plus_indexes IS 'Total size (pretty) of data, TOAST, and indexes.  Suitable for display';
COMMENT ON COLUMN dd.schemas.size_pretty IS 'Size (pretty) of data and TOAST.  Does not include indexes. Suitable for display';
COMMENT ON COLUMN dd.schemas.size_bytes IS 'Size (bytes) of data and TOAST.  Does not include indexes. Suitable for sorting. ';

COMMENT ON COLUMN dd.tables.size_plus_indexes IS 'Total size (pretty) of data, TOAST, and indexes.  Suitable for display';
COMMENT ON COLUMN dd.tables.size_pretty IS 'Size (pretty) of data and TOAST.  Does not include indexes. Suitable for display';
COMMENT ON COLUMN dd.tables.size_bytes IS 'Size (bytes) of data and TOAST.  Does not include indexes. Suitable for sorting. ';
