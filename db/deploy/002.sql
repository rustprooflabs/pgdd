-- Deploy pgdd:002 to pg

BEGIN;

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


COMMIT;
