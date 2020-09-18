use pgx::*;

pg_module_magic!();


extension_sql!(
    r#"
COMMENT ON SCHEMA dd IS 'Data Dictionary from https://github.com/rustprooflabs/pgdd';

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
"#
);


#[pg_extern]
fn schemas(
) -> impl std::iter::Iterator<Item = (name!(s_name, Option<String>),
                                        name!(owner, Option<String>),
                                        name!(data_source, Option<String>),
                                        name!(sensitive, Option<bool>),
                                        name!(description, Option<String>),
                                        name!(system_object, Option<bool>),
                                        name!(table_count, Option<i64>),
                                        name!(view_count, Option<i64>),
                                        name!(function_count, Option<i64>),
                                        name!(size_pretty, Option<String>),
                                        name!(size_plus_indexes, Option<String>),
                                        name!(size_bytes, Option<i64>))>
{
    let query = include_str!("schemas-all.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row.get_datum(1), row.get_datum(2),
                        row.get_datum(3), row.get_datum(4),
                        row.get_datum(5), row.get_datum(6),
                        row.get_datum(7), row.get_datum(8),
                        row.get_datum(9), row.get_datum(10),
                        row.get_datum(11), row.get_datum(12)))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });

    results.into_iter()
}

#[pg_extern]
fn columns(
) -> impl std::iter::Iterator<Item = (name!(s_name, Option<String>),
                                        name!(source_type, Option<String>),
                                        name!(t_name, Option<String>),
                                        name!(c_name, Option<String>),
                                        name!(data_type, Option<String>),
                                        name!(position, Option<i64>),
                                        name!(description, Option<String>),
                                        name!(data_source, Option<String>),
                                        name!(sensitive, Option<bool>),
                                        name!(system_object, Option<bool>),
                                        name!(default_value, Option<String>),
                                        name!(generated_column, Option<bool>))>
{
    #[cfg(feature = "pg10")]
    let query = include_str!("columns-pre-12.sql");
    #[cfg(feature = "pg11")]
    let query = include_str!("columns-pre-12.sql");
    #[cfg(feature = "pg12")]
    let query = include_str!("columns-12.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row.get_datum(1), row.get_datum(2),
                        row.get_datum(3), row.get_datum(4),
                        row.get_datum(5), row.get_datum(6),
                        row.get_datum(7), row.get_datum(8),
                        row.get_datum(9), row.get_datum(10),
                        row.get_datum(11), row.get_datum(12)))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });

    results.into_iter()
}


#[pg_extern]
fn functions(
) -> impl std::iter::Iterator<Item = (name!(s_name, Option<String>),
                                        name!(f_name, Option<String>),
                                        name!(result_data_types, Option<String>),
                                        name!(argument_data_types, Option<String>),
                                        name!(owned_by, Option<String>),
                                        name!(proc_security, Option<String>),
                                        name!(access_privileges, Option<String>),
                                        name!(proc_language, Option<String>),
                                        name!(source_code, Option<String>),
                                        name!(description, Option<String>),
                                        name!(system_object, Option<bool>))>
{
    let query = include_str!("functions-all.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row.get_datum(1), row.get_datum(2),
                        row.get_datum(3), row.get_datum(4),
                        row.get_datum(5), row.get_datum(6),
                        row.get_datum(7), row.get_datum(8),
                        row.get_datum(9), row.get_datum(10),
                        row.get_datum(11)))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });

    results.into_iter()
}



#[pg_extern]
fn tables(
) -> impl std::iter::Iterator<Item = (name!(s_name, Option<String>),
                                        name!(t_name, Option<String>),
                                        name!(type, Option<String>),
                                        name!(owned_by, Option<String>),
                                        name!(size_pretty, Option<String>),
                                        name!(size_bytes, Option<i64>),
                                        name!(rows, Option<i64>),
                                        name!(bytes_per_row, Option<i64>),
                                        name!(size_plus_indexes, Option<String>),
                                        name!(description, Option<String>),
                                        name!(system_object, Option<bool>),
                                        name!(data_source, Option<String>),
                                        name!(sensitive, Option<bool>))>
{
    let query = include_str!("tables-all.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row.get_datum(1), row.get_datum(2),
                        row.get_datum(3), row.get_datum(4),
                        row.get_datum(5), row.get_datum(6),
                        row.get_datum(7), row.get_datum(8),
                        row.get_datum(9), row.get_datum(10),
                        row.get_datum(11), row.get_datum(12),
                        row.get_datum(13)))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });

    results.into_iter()
}




#[pg_extern]
fn about() -> &'static str {
    "PgDD: PostgreSQL Data Dictionary extension.  See https://github.com/rustprooflabs/pgdd for details!"
}



#[cfg(any(test, feature = "pg_test"))]
mod tests {
    use pgx::*;

    #[pg_test]
    fn test_hello_pgdd_rust() {
        assert_eq!("Hello, pgdd_rust", crate::hello_pgdd_rust());
    }

}

#[cfg(test)]
pub mod pg_test {
    pub fn setup(_options: Vec<&str>) {
        // perform one-off initialization when the pg_test framework starts
    }

    pub fn postgresql_conf_options() -> Vec<&'static str> {
        // return any postgresql.conf settings that are required for your tests
        vec![]
    }
}
