
COMMENT ON SCHEMA dd IS 'Schema for Data Dictionary objects.  See https://github.com/rustprooflabs/pgdd';

COMMENT ON TABLE dd.meta_schema IS 'User definable meta-data at the schema level.';
COMMENT ON TABLE dd.meta_table IS 'User definable meta-data at the schema + table level.';
COMMENT ON TABLE dd.meta_column IS 'User definable meta-data at the schema + table + column level.';

COMMENT ON COLUMN dd.meta_schema.meta_schema_id IS 'Primary key for meta table';
COMMENT ON COLUMN dd.meta_table.meta_table_id IS 'Primary key for meta table';
COMMENT ON COLUMN dd.meta_column.meta_column_id IS 'Primary key for meta table';
COMMENT ON COLUMN dd.meta_schema.s_name IS 'Name of the schema for the object described.';
COMMENT ON COLUMN dd.meta_table.s_name IS 'Name of the schema for the object described.';
COMMENT ON COLUMN dd.meta_column.s_name IS 'Name of the schema for the object described.';
COMMENT ON COLUMN dd.meta_table.t_name IS 'Name of the table for the object described.';
COMMENT ON COLUMN dd.meta_column.t_name IS 'Name of the table for the object described.';
COMMENT ON COLUMN dd.meta_column.c_name IS 'Name of the column for the object described.';

COMMENT ON COLUMN dd.meta_schema.data_source IS 'Optional field to describe the data source(s) for the data in this schema.  Most helpful when objects are intentionally organized by schema.';
COMMENT ON COLUMN dd.meta_table.data_source IS 'Optional field to describe the data source(s) for this table.';
COMMENT ON COLUMN dd.meta_column.data_source IS 'Optional field to describe the data source(s) for this column.';
COMMENT ON COLUMN dd.meta_schema.sensitive IS 'Manually updated indicator. Does the schema contain store sensitive data?';
COMMENT ON COLUMN dd.meta_table.sensitive IS 'Manually updated indicator. Does the table contain store sensitive data?';
COMMENT ON COLUMN dd.meta_column.sensitive IS 'Manually updated indicator. Does the column contain store sensitive data?';


COMMENT ON VIEW dd.schemas IS 'Data dictionary view: Lists schemas, excluding system schemas.';
COMMENT ON VIEW dd.tables IS 'Data dictionary view: Lists tables, excluding system tables.';
COMMENT ON VIEW dd.views IS 'Data dictionary view: Lists views, excluding system views.';
COMMENT ON VIEW dd.columns IS 'Data dictionary view: Lists columns, excluding system columns.';
COMMENT ON VIEW dd.functions IS 'Data dictionary view: Lists functions, excluding system functions.';

COMMENT ON FUNCTION dd.about IS 'Basic details about PgDD extension';

COMMENT ON FUNCTION dd.schemas IS 'Data dictionary function: Lists all schemas';
COMMENT ON FUNCTION dd.tables IS 'Data dictionary function: Lists all tables';
COMMENT ON FUNCTION dd.views IS 'Data dictionary function: Lists all views.';
COMMENT ON FUNCTION dd.columns IS 'Data dictionary function: Lists all columns';
COMMENT ON FUNCTION dd.functions IS 'Data dictionary function: Lists all functions';
COMMENT ON FUNCTION dd.partition_parent IS 'Data dictionary function: Lists parent partition tables. Column partition_type indicates declarative vs inheritance based partitioning.';
COMMENT ON FUNCTION dd.partition_child IS 'Data dictionary function: Lists partition child tables.';
