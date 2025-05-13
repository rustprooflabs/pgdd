CREATE VIEW dd.functions_all AS
SELECT n.nspname::TEXT AS s_name,
        p.proname::TEXT AS f_name,
        pg_get_function_result(p.oid)::TEXT AS result_data_types,
        pg_get_function_arguments(p.oid)::TEXT AS argument_data_types,
        pg_get_userbyid(p.proowner)::TEXT AS owned_by,
            CASE
                WHEN p.prosecdef THEN 'definer'::text
                ELSE 'invoker'::text
            END AS proc_security,
        array_to_string(p.proacl, ''::text) AS access_privileges,
        l.lanname::TEXT AS proc_language,
        p.prosrc::TEXT AS source_code,
        obj_description(p.oid, 'pg_proc'::name)::TEXT AS description,
        CASE
            WHEN n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name]) THEN false
            ELSE true
        END AS system_object
   FROM pg_proc p
     LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
     LEFT JOIN pg_language l ON l.oid = p.prolang
;


CREATE OR REPLACE VIEW dd.functions AS
SELECT * FROM dd.functions_all
    WHERE NOT system_object
;

