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
		  pg_catalog.obj_description(c.oid, 'pg_class') AS description,
		  mt.data_source, mt.sensitive
		FROM pg_catalog.pg_class c
	    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	    LEFT JOIN dd.meta_table mt ON n.nspname = mt.s_name AND c.relname = mt.t_name
		WHERE c.relkind IN ('r','p','s', 'f')
	      	AND n.nspname !~ '^pg_toast'
	      	AND n.nspname NOT IN ('pg_catalog', 'information_schema')
	;


