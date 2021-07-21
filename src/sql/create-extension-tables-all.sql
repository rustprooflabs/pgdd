CREATE TABLE dd.meta_schema
(
    meta_schema_id SERIAL NOT NULL,
    s_name name NOT NULL,
    data_source TEXT NULL,
    sensitive BOOLEAN NOT NULL,
    CONSTRAINT PK_dd_meta_schema_id PRIMARY KEY (meta_schema_id),
    CONSTRAINT UQ_dd_meta_schema_name UNIQUE (s_name)
);


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

----------------------
-- Version 0.4.0 -- This is duplicated in sql/pgdd--0.3.1--0.4.0.sql
----------------------
ALTER TABLE dd.meta_schema ALTER COLUMN sensitive SET DEFAULT False;
