
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


COMMENT ON VIEW dd.tables IS 'Data dictionary view: Lists tables, excluding system tables.';
COMMENT ON VIEW dd.views IS 'Data dictionary view: Lists views, excluding system views.';
COMMENT ON VIEW dd.columns IS 'Data dictionary view: Lists columns, excluding system columns.';
COMMENT ON VIEW dd.functions IS 'Data dictionary view: Lists functions, excluding system functions.';

COMMENT ON FUNCTION dd.about IS 'Basic details about PgDD extension';

COMMENT ON VIEW dd.tables_all IS 'Data dictionary view: Lists all tables';
COMMENT ON VIEW dd.views_all IS 'Data dictionary view: Lists all views.';
COMMENT ON VIEW dd.columns_all IS 'Data dictionary view: Lists all columns';
COMMENT ON VIEW dd.functions_all IS 'Data dictionary view: Lists all functions';
COMMENT ON VIEW dd.partition_parents_all IS 'Data dictionary view: Lists parent partition tables. Column partition_type indicates declarative vs inheritance based partitioning.';
COMMENT ON VIEW dd.partition_child_all IS 'Data dictionary view: Lists partition child tables.';

COMMENT ON VIEW dd.partition_parents IS 'Data dictionary view: Lists parent partition tables with aggregate details about child partitions.';
COMMENT ON COLUMN dd.partition_parents.partition_type IS 'Options declarative and inheritance. Declarative determined by record existing in pg_catalog.pg_partitioned_table. Inheritance based on pg_class.relkind.';
COMMENT ON COLUMN dd.partition_parents.partitions IS 'Count of matching records found in pg_catalog.pg_inherits.';
COMMENT ON COLUMN dd.partition_parents.size_bytes IS 'Sum of size_bytes from matching dd.tables records.';
COMMENT ON COLUMN dd.partition_parents.size_pretty IS 'Size pretty of the size_bytes calculation.';
COMMENT ON COLUMN dd.partition_parents.size_per_partition IS 'size_bytes per partition, pretty format.';
COMMENT ON COLUMN dd.partition_parents.rows IS 'Sum of estimated row counts from matching dd.tables records for all partitions';
COMMENT ON COLUMN dd.partition_parents.rows_per_partition IS 'rows per partition';
COMMENT ON COLUMN dd.partition_parents.partitions_never_analyzed IS 'Number of partition_children that have not been analyzed. New for Postgres 14.';
COMMENT ON COLUMN dd.partition_parents.partitions_no_data IS 'Number of partition_children with 0 rows of data.';

COMMENT ON VIEW dd.partition_children IS 'Data dictionary view: Lists individual partitions (children) of partitioned tables.';
COMMENT ON COLUMN dd.partition_children.parent_oid IS 'oid for the parent of this partitioned table';
COMMENT ON COLUMN dd.partition_children.parent_name IS 'Name of parent partition table, format s_name.t_name.';
COMMENT ON COLUMN dd.partition_children.rows IS 'Estimated row count of this partition.';
COMMENT ON COLUMN dd.partition_children.size_bytes IS 'Size in bytes from dd.tables()';
COMMENT ON COLUMN dd.partition_children.size_pretty IS 'Size pretty from dd.tables().';
COMMENT ON COLUMN dd.partition_children.size_plus_indexes IS 'Size pretty of the table plus indexes';
COMMENT ON COLUMN dd.partition_children.bytes_per_row IS 'Average size per row in bytes';
COMMENT ON COLUMN dd.partition_children.percent_of_partition_rows IS 'Percent of the total row count found in all partitions of the parent table.';
COMMENT ON COLUMN dd.partition_children.percent_of_partition_bytes IS 'Percent of the total size (bytes) used by all partitions of the parent table.';

COMMENT ON VIEW dd.database IS 'Data dictionary view: Provides basic statistics for the current database.';
COMMENT ON COLUMN dd.database.db_size IS 'Size pretty of current database.  Uses pg_database_size() function.';
COMMENT ON COLUMN dd.database.schema_count IS 'Count of non-system schemas, uses dd.schemas view.';
COMMENT ON COLUMN dd.database.table_count IS 'Count of non-system tables, uses dd.tables view.';
COMMENT ON COLUMN dd.database.extension_count IS 'Count of extensions installed in database.';

COMMENT ON VIEW dd.index IS 'Data dictionary view: Details about indexes in current database.';
COMMENT ON COLUMN dd.index.oid IS 'OID for the index.';
COMMENT ON COLUMN dd.index.s_name IS 'Name of the schema for the index described.';
COMMENT ON COLUMN dd.index.t_name IS 'Name of the table for the index described.';
COMMENT ON COLUMN dd.index.i_name IS 'Name of the index';
COMMENT ON COLUMN dd.index.key_columns IS 'Number of columns actually indexed.  Does not count INCLUDE columns. Source: pg_catalog.pg_index.indnkeyatts';
COMMENT ON COLUMN dd.index.total_columns IS 'Total number of columns involved, includes INCLUDE columns.  Source: pg_catalog.pg_index.indnatts';
COMMENT ON COLUMN dd.index.primary_key IS 'Indicates if index is primary key.  Source: pg_catalog.pg_index.indisprimary';
COMMENT ON COLUMN dd.index.unique_index IS 'Indicates if index is unique index.  Source: pg_catalog.pg_index.indisunique';
COMMENT ON COLUMN dd.index.valid_index IS 'Indicates if index is valid.  Source: pg_catalog.pg_index.indisvalid';
COMMENT ON COLUMN dd.index.partial_index IS 'Indicates if index is partial (filtered) index.  Source: pg_catalog.pg_index.indpred';
COMMENT ON COLUMN dd.index.rows_indexed IS 'Estimated number of rows included in the index';
COMMENT ON COLUMN dd.index.index_size IS 'Size of the index formatted for display, reported by pg_size_pretty(pg_total_relation_size()).';
COMMENT ON COLUMN dd.index.index_size_bytes IS 'Size of the index in bytes reported by pg_total_relation_size().';


