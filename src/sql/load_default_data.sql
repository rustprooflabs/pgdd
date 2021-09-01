INSERT INTO dd.meta_schema (s_name, data_source, sensitive)
    VALUES ('dd', 'Manually maintained', False);


INSERT INTO dd.meta_table (s_name, t_name, data_source, sensitive)
    VALUES ('dd', 'meta_schema', 'Manually maintained', False);
INSERT INTO dd.meta_table (s_name, t_name, data_source, sensitive)
    VALUES ('dd', 'meta_table', 'Manually maintained', False);
INSERT INTO dd.meta_table (s_name, t_name, data_source, sensitive)
    VALUES ('dd', 'meta_column', 'Manually maintained', False);


INSERT INTO dd.meta_column (s_name, t_name, c_name, data_source, sensitive)
    VALUES ('dd', 'meta_column', 'sensitive', 'Manually defined', False)
;

SELECT pg_catalog.pg_extension_config_dump('dd.meta_schema'::regclass, 'WHERE s_name <> ''dd'' ');
SELECT pg_catalog.pg_extension_config_dump('dd.meta_schema_meta_schema_id_seq'::regclass, '');

SELECT pg_catalog.pg_extension_config_dump('dd.meta_table'::regclass, 'WHERE s_name <> ''dd'' ');
SELECT pg_catalog.pg_extension_config_dump('dd.meta_table_meta_table_id_seq'::regclass, '');

SELECT pg_catalog.pg_extension_config_dump('dd.meta_column'::regclass, 'WHERE s_name <> ''dd'' ');
SELECT pg_catalog.pg_extension_config_dump('dd.meta_column_meta_column_id_seq'::regclass, '');
