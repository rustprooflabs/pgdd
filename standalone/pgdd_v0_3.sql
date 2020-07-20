
CREATE SCHEMA dd;
COMMENT ON SCHEMA dd IS 'Data Dictionary from https://github.com/rustprooflabs/pgdd';
----------------------------------------

CREATE TABLE dd.meta_schema
(
	meta_schema_id SERIAL NOT NULL,
	s_name name NOT NULL,
	data_source TEXT NULL,
	sensitive BOOLEAN NOT NULL,
	CONSTRAINT PK_dd_meta_schema_id PRIMARY KEY (meta_schema_id),
	CONSTRAINT UQ_dd_meta_schema_name UNIQUE (s_name)
);

COMMENT ON TABLE dd.meta_schema 
	IS 'User definable meta-data at the schema level.'
;

COMMENT ON COLUMN dd.meta_schema.s_name
	IS 'Schema name.'
;

INSERT INTO dd.meta_schema (s_name, data_source, sensitive)
	VALUES ('dd', 'Manually maintained', False);

----------------------------------------

CREATE TABLE dd.meta_table
(
	meta_table_id SERIAL NOT NULL,
	s_name name NOT NULL,
	t_name name NOT NULL,
	data_source TEXT NULL,
	sensitive BOOLEAN NOT NULL DEFAULT False,
	CONSTRAINT PK_dd_meta_table_id PRIMARY KEY (meta_table_id),
	CONSTRAINT UQ_dd_meta_table_schema_table UNIQUE (s_name, t_name)
);


COMMENT ON TABLE dd.meta_table 
	IS 'User definable meta-data at the schema + table level.'
;

----------------------------------------


CREATE TABLE dd.meta_column
(
	meta_column_id SERIAL NOT NULL,
	s_name name NOT NULL,
	t_name name NOT NULL,
	c_name name NOT NULL,
	data_source TEXT NULL,
	sensitive BOOLEAN NOT NULL DEFAULT False,
	CONSTRAINT PK_dd_meta_column_id PRIMARY KEY (meta_column_id),
	CONSTRAINT UQ_dd_meta_column_schema_table_column UNIQUE (s_name, t_name, c_name)
);


COMMENT ON TABLE dd.meta_column 
	IS 'User definable meta-data at the schema + table + column level.'
;


INSERT INTO dd.meta_table (s_name, t_name, data_source, sensitive)
	VALUES ('dd', 'meta_schema', 'Manually maintained', False);
INSERT INTO dd.meta_table (s_name, t_name, data_source, sensitive)
	VALUES ('dd', 'meta_table', 'Manually maintained', False);
INSERT INTO dd.meta_table (s_name, t_name, data_source, sensitive)
	VALUES ('dd', 'meta_column', 'Manually maintained', False);




COMMENT ON COLUMN dd.meta_column.sensitive
	IS 'Indicates if the column stores sensitive data.'
;

INSERT INTO dd.meta_column (s_name, t_name, c_name, data_source, sensitive)
	VALUES ('dd', 'meta_column', 'sensitive', 'Manually defined', False)
;

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
		SUM(pg_catalog.pg_table_size(c.oid)) AS size_bytes
	FROM s
	LEFT JOIN pg_catalog.pg_class c 
		ON s.oid = c.relnamespace AND c.relkind IN ('r','p')
	GROUP BY s.s_name, s.owner, s.data_source, s.sensitive, s.description
;


----------------------------------------


CREATE VIEW dd.columns AS
SELECT n.nspname AS s_name,
		CASE c.relkind WHEN 'r' THEN 'table' 
			WHEN 'v' THEN 'view'
			WHEN 'm' THEN 'materialized view'
			WHEN 's' THEN 'special'
			WHEN 'f' THEN 'foreign table'
			WHEN 'p' THEN 'table'
		END AS type,
		c.relname AS t_name,
		a.attname AS column_name,
		t.typname AS data_type, a.attnum AS position,
		pg_catalog.col_description(c.oid, a.attnum) AS description,
		mc.data_source, mc.sensitive
	FROM pg_catalog.pg_attribute a
	INNER JOIN pg_catalog.pg_class c ON a.attrelid = c.oid
	INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	INNER JOIN pg_catalog.pg_type t ON a.atttypid = t.oid
	LEFT JOIN dd.meta_column mc
		ON n.nspname = mc.s_name AND c.relname = mc.t_name AND a.attname = mc.c_name
		WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
			AND n.nspname !~ '^pg_toast'
			AND a.attnum > 0
			AND c.relkind IN ('r','p','s', 'v', 'f', 'm')
	;



CREATE VIEW dd.tables AS
	SELECT n.nspname AS s_name,
		  	c.relname as t_name,
		  	CASE WHEN c.relkind IN ('r', 'p') THEN 'table' 
		  		WHEN c.relkind = 's' THEN 'special'
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
		WHERE c.relkind IN ('r','p','s')
	      	AND n.nspname !~ '^pg_toast'
	      	AND n.nspname NOT IN ('pg_catalog', 'information_schema')
	;



	CREATE VIEW dd.functions AS
		SELECT n.nspname AS s_name,
	  		p.proname AS f_name,
	  		pg_catalog.pg_get_function_result(p.oid) AS result_data_types,
	  		pg_catalog.pg_get_function_arguments(p.oid) AS argument_data_types,
			pg_catalog.pg_get_userbyid(p.proowner) as "Owner",
			CASE WHEN prosecdef 
				THEN 'definer' 
				ELSE 'invoker' 
			END AS proc_security,
			pg_catalog.array_to_string(p.proacl, E'\n') AS access_privileges,
			l.lanname AS proc_language,
			p.prosrc AS source_code,
			pg_catalog.obj_description(p.oid, 'pg_proc') AS description
		FROM pg_catalog.pg_proc p
	    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
	    LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang
	    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
	;


	COMMENT ON VIEW dd.functions IS 'Data dictionary view:  Lists functions (procedures)';

	COMMENT ON VIEW dd.schemas IS 'Data dictionary view:  Lists schemas';
	COMMENT ON VIEW dd.tables IS 'Data dictionary view:  Lists tables';
	COMMENT ON VIEW dd.columns IS 'Data dictionary view:  Lists columns in tables';



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

-- dd."schemas" source

DROP VIEW dd."schemas";

CREATE VIEW dd."schemas"
AS WITH s AS (
         SELECT n.oid,
            n.nspname AS s_name,
            pg_get_userbyid(n.nspowner) AS owner,
            ms.data_source,
            ms.sensitive,
            obj_description(n.oid, 'pg_namespace'::name) AS description,
            CASE WHEN n.nspname !~ '^pg_'::text
                    AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]))
                THEN False
                ELSE True
                END AS system_object
           FROM pg_namespace n
             LEFT JOIN dd.meta_schema ms ON n.nspname = ms.s_name
        ),
    f AS (
        SELECT n.nspname AS s_name, COUNT(DISTINCT p.oid) AS function_count
            FROM pg_catalog.pg_proc p
            INNER JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
            GROUP BY n.nspname
        ),
    v AS (
        SELECT n.nspname AS s_name, COUNT(DISTINCT c.oid) AS view_count
            FROM pg_catalog.pg_class c
            INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relkind IN ('v', 'm')
        GROUP BY n.nspname 
        )
 SELECT s.s_name,
    s.owner,
    s.data_source,
    s.sensitive,
    s.description,
    s.system_object,
    COALESCE(COUNT(c.*), 0::BIGINT)::BIGINT AS table_count,
    COALESCE(v.view_count, 0)::BIGINT AS view_count,
    COALESCE(f.function_count, 0)::BIGINT AS function_count,
    pg_size_pretty(SUM(pg_table_size(c.oid::regclass))) AS size_pretty,
    pg_size_pretty(SUM(pg_total_relation_size(c.oid::regclass))) AS size_plus_indexes,
    SUM(pg_table_size(c.oid::regclass)) AS size_bytes
   FROM s
     LEFT JOIN pg_class c ON s.oid = c.relnamespace AND (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]))
     LEFT JOIN f ON f.s_name = s.s_name
     LEFT JOIN v ON v.s_name = s.s_name
  GROUP BY s.s_name, s.owner, s.data_source,
        s.sensitive, s.description, s.system_object,
        v.view_count, f.function_count
 ;



DROP VIEW dd."tables";
CREATE VIEW dd."tables"
AS SELECT n.nspname AS s_name,
    c.relname AS t_name,
        CASE
            WHEN c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]) THEN 'table'::text
            WHEN c.relkind = 's'::"char" THEN 'special'::text
            WHEN c.relkind = 'f'::"char" THEN 'foreign table'::text
            ELSE NULL::text
        END AS type,
    pg_get_userbyid(c.relowner) AS owner,
    pg_size_pretty(pg_table_size(c.oid::regclass)) AS size_pretty,
    pg_table_size(c.oid::regclass) AS size_bytes,
    c.reltuples AS rows,
        CASE
            WHEN c.reltuples > 0::double precision THEN pg_table_size(c.oid::regclass)::double precision / c.reltuples
            ELSE NULL::double precision
        END AS bytes_per_row,
    pg_size_pretty(pg_total_relation_size(c.oid::regclass)) AS size_plus_indexes,
    obj_description(c.oid, 'pg_class'::name) AS description,
    CASE WHEN n.nspname !~ '^pg_toast'::text AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]))
        THEN False
        ELSE True
        END AS system_object,
    mt.data_source,
    mt.sensitive
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN dd.meta_table mt ON n.nspname = mt.s_name AND c.relname = mt.t_name
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char", 's'::"char", 'f'::"char"]))
;


-- dd."views" source
DROP VIEW dd."views";
CREATE VIEW dd."views"
AS SELECT n.nspname AS s_name,
    c.relname AS v_name,
        CASE c.relkind
            WHEN 'v'::"char" THEN 'view'::text
            WHEN 'm'::"char" THEN 'materialized view'::text
            ELSE NULL::text
        END AS view_type,
    pg_get_userbyid(c.relowner) AS owner,
    c.reltuples AS rows,
    pg_size_pretty(pg_table_size(c.oid::regclass)) AS size_pretty,
    pg_table_size(c.oid::regclass) AS size_bytes,
    obj_description(c.oid, 'pg_class'::name) AS description,
    CASE WHEN n.nspname !~ '^pg_toast'::text AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]))
        THEN False
        ELSE True
        END AS system_object
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE (c.relkind = ANY (ARRAY['v'::"char", 'm'::"char"])) AND n.nspname !~ '^pg_toast'::text;



DROP VIEW dd."columns";
CREATE VIEW dd."columns"
AS SELECT n.nspname AS s_name,
        CASE c.relkind
            WHEN 'r'::"char" THEN 'table'::text
            WHEN 'v'::"char" THEN 'view'::text
            WHEN 'm'::"char" THEN 'materialized view'::text
            WHEN 's'::"char" THEN 'special'::text
            WHEN 'f'::"char" THEN 'foreign table'::text
            WHEN 'p'::"char" THEN 'table'::text
            ELSE NULL::text
        END AS type,
    c.relname AS t_name,
    a.attname AS column_name,
    t.typname AS data_type,
    a.attnum AS "position",
    col_description(c.oid, a.attnum::integer) AS description,
    mc.data_source,
    mc.sensitive,
    CASE WHEN (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])) AND n.nspname !~ '^pg_toast'::text
        THEN False
        ELSE True
        END AS system_object
   FROM pg_attribute a
     JOIN pg_class c ON a.attrelid = c.oid
     JOIN pg_namespace n ON n.oid = c.relnamespace
     JOIN pg_type t ON a.atttypid = t.oid
     LEFT JOIN dd.meta_column mc ON n.nspname = mc.s_name AND c.relname = mc.t_name AND a.attname = mc.c_name
  WHERE a.attnum > 0 AND (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char", 's'::"char", 'v'::"char", 'f'::"char", 'm'::"char"]))
;



DROP VIEW dd."functions";
CREATE VIEW dd."functions"
AS SELECT n.nspname AS s_name,
    p.proname AS f_name,
    pg_get_function_result(p.oid) AS result_data_types,
    pg_get_function_arguments(p.oid) AS argument_data_types,
    pg_get_userbyid(p.proowner) AS "Owner",
        CASE
            WHEN p.prosecdef THEN 'definer'::text
            ELSE 'invoker'::text
        END AS proc_security,
    array_to_string(p.proacl, ''::text) AS access_privileges,
    l.lanname AS proc_language,
    p.prosrc AS source_code,
    obj_description(p.oid, 'pg_proc'::name) AS description,
    CASE WHEN n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])
        THEN False
        ELSE True
        END AS system_object
   FROM pg_proc p
     LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
     LEFT JOIN pg_language l ON l.oid = p.prolang
;


COMMENT ON VIEW dd.schemas IS 'Data dictionary view:  Lists schemas';
COMMENT ON VIEW dd.tables IS 'Data dictionary view:  Lists tables';
COMMENT ON VIEW dd.views IS 'Data dictionary view:  Lists views and materialized views';
COMMENT ON VIEW dd.functions IS 'Data dictionary view:  Lists functions (procedures)';
COMMENT ON VIEW dd.columns IS 'Data dictionary view:  Lists columns in tables';

COMMENT ON COLUMN dd.schemas.size_plus_indexes IS 'Total size (pretty) of data, TOAST, and indexes.  Suitable for display';
COMMENT ON COLUMN dd.schemas.size_pretty IS 'Size (pretty) of data and TOAST.  Does not include indexes. Suitable for display';
COMMENT ON COLUMN dd.schemas.size_bytes IS 'Size (bytes) of data and TOAST.  Does not include indexes. Suitable for sorting. ';

COMMENT ON COLUMN dd.tables.size_plus_indexes IS 'Total size (pretty) of data, TOAST, and indexes.  Suitable for display';
COMMENT ON COLUMN dd.tables.size_pretty IS 'Size (pretty) of data and TOAST.  Does not include indexes. Suitable for display';
COMMENT ON COLUMN dd.tables.size_bytes IS 'Size (bytes) of data and TOAST.  Does not include indexes. Suitable for sorting. ';

COMMENT ON COLUMN dd.schemas.system_object IS 'Allows to easily show/hide system objects.';
COMMENT ON COLUMN dd.tables.system_object IS 'Allows to easily show/hide system objects.';
COMMENT ON COLUMN dd.views.system_object IS 'Allows to easily show/hide system objects.';
COMMENT ON COLUMN dd.functions.system_object IS 'Allows to easily show/hide system objects.';
COMMENT ON COLUMN dd.columns.system_object IS 'Allows to easily show/hide system objects.';

