use pgx::*;

pg_module_magic!();

// WARNING:  DO NOT CHANGE DDL after it has been released!
//  Changed DDL are ignored by pgx schema generated and will NOT be deployed
//  when users run ALTER EXTENSION pgdd UPDATE;
//extension_sql!(
 //   r#"
//"#
//);

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
            .map(|row| (row.by_ordinal(1).unwrap().value::<String>(),
                        row.by_ordinal(2).unwrap().value::<String>(),
                        row.by_ordinal(3).unwrap().value::<String>(),
                        row.by_ordinal(4).unwrap().value::<bool>(),
                        row.by_ordinal(5).unwrap().value::<String>(),
                        row.by_ordinal(6).unwrap().value::<bool>(),
                        row.by_ordinal(7).unwrap().value::<i64>(),
                        row.by_ordinal(8).unwrap().value::<i64>(),
                        row.by_ordinal(9).unwrap().value::<i64>(),
                        row.by_ordinal(10).unwrap().value::<String>(),
                        row.by_ordinal(11).unwrap().value::<String>(),
                        row.by_ordinal(12).unwrap().value::<i64>()
                        ))
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
    #[cfg(any(feature = "pg10", feature="pg11"))]
    let query = include_str!("columns-pre-12.sql");
    #[cfg(any(feature = "pg12", feature="pg13"))]
    let query = include_str!("columns-12.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row.by_ordinal(1).unwrap().value::<String>(),
                        row.by_ordinal(2).unwrap().value::<String>(),
                        row.by_ordinal(3).unwrap().value::<String>(),
                        row.by_ordinal(4).unwrap().value::<String>(),
                        row.by_ordinal(5).unwrap().value::<String>(),
                        row.by_ordinal(6).unwrap().value::<i64>(),
                        row.by_ordinal(7).unwrap().value::<String>(),
                        row.by_ordinal(8).unwrap().value::<String>(),
                        row.by_ordinal(9).unwrap().value::<bool>(),
                        row.by_ordinal(10).unwrap().value::<bool>(),
                        row.by_ordinal(11).unwrap().value::<String>(),
                        row.by_ordinal(12).unwrap().value::<bool>()
                        ))
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
            .map(|row| (row.by_ordinal(1).unwrap().value::<String>(),
                        row.by_ordinal(2).unwrap().value::<String>(),
                        row.by_ordinal(3).unwrap().value::<String>(),
                        row.by_ordinal(4).unwrap().value::<String>(),
                        row.by_ordinal(5).unwrap().value::<String>(),
                        row.by_ordinal(6).unwrap().value::<String>(),
                        row.by_ordinal(7).unwrap().value::<String>(),
                        row.by_ordinal(8).unwrap().value::<String>(),
                        row.by_ordinal(9).unwrap().value::<String>(),
                        row.by_ordinal(10).unwrap().value::<String>(),
                        row.by_ordinal(11).unwrap().value::<bool>()
                        ))
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
            .map(|row| (row.by_ordinal(1).unwrap().value::<String>(),
                        row.by_ordinal(2).unwrap().value::<String>(),
                        row.by_ordinal(3).unwrap().value::<String>(),
                        row.by_ordinal(4).unwrap().value::<String>(),
                        row.by_ordinal(5).unwrap().value::<String>(),
                        row.by_ordinal(6).unwrap().value::<i64>(),
                        row.by_ordinal(7).unwrap().value::<i64>(),
                        row.by_ordinal(8).unwrap().value::<i64>(),
                        row.by_ordinal(9).unwrap().value::<String>(),
                        row.by_ordinal(10).unwrap().value::<String>(),
                        row.by_ordinal(11).unwrap().value::<bool>(),
                        row.by_ordinal(12).unwrap().value::<String>(),
                        row.by_ordinal(13).unwrap().value::<bool>()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });

    results.into_iter()
}



#[pg_extern]
fn views(
) -> impl std::iter::Iterator<Item = (name!(s_name, Option<String>),
                                        name!(v_name, Option<String>),
                                        name!(view_type, Option<String>),
                                        name!(owned_by, Option<String>),
                                        name!(rows, Option<i64>),
                                        name!(size_pretty, Option<String>),
                                        name!(size_bytes, Option<i64>),
                                        name!(description, Option<String>),
                                        name!(system_object, Option<bool>))>
{
    let query = include_str!("views-all.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row.by_ordinal(1).unwrap().value::<String>(),
                        row.by_ordinal(2).unwrap().value::<String>(),
                        row.by_ordinal(3).unwrap().value::<String>(),
                        row.by_ordinal(4).unwrap().value::<String>(),
                        row.by_ordinal(5).unwrap().value::<i64>(),
                        row.by_ordinal(6).unwrap().value::<String>(),
                        row.by_ordinal(7).unwrap().value::<i64>(),
                        row.by_ordinal(8).unwrap().value::<String>(),
                        row.by_ordinal(9).unwrap().value::<bool>()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });

    results.into_iter()
}


#[pg_extern]
fn about() -> &'static str {
    "PgDD: PostgreSQL Data Dictionary extension.  See https://github.com/rustprooflabs/pgdd for details!"
}

#[pg_extern]
fn version() -> &'static str {
    let version = env!("CARGO_PKG_VERSION");
    version
}



extension_sql!(
    r#"
CREATE OR REPLACE VIEW dd.schemas AS
SELECT * FROM dd.schemas()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.tables AS
SELECT * FROM dd.tables()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.views AS
SELECT * FROM dd.views()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.columns AS
SELECT * FROM dd.columns()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.functions AS
SELECT * FROM dd.functions()
    WHERE NOT system_object
;


COMMENT ON VIEW dd.schemas IS 'Data dictionary view: Lists schemas, excluding system schemas.';
COMMENT ON VIEW dd.tables IS 'Data dictionary view: Lists tables, excluding system tables.';
COMMENT ON VIEW dd.views IS 'Data dictionary view: Lists views, excluding system views.';
COMMENT ON VIEW dd.columns IS 'Data dictionary view: Lists columns, excluding system columns.';
COMMENT ON VIEW dd.functions IS 'Data dictionary view: Lists functions, excluding system functions.';

COMMENT ON FUNCTION dd.about IS 'Basic details about PgDD extension';
COMMENT ON FUNCTION dd.version IS 'PgDD extension version';

COMMENT ON FUNCTION dd.schemas IS 'Data dictionary function: Lists all schemas';
COMMENT ON FUNCTION dd.tables IS 'Data dictionary function: Lists all tables';
COMMENT ON FUNCTION dd.views IS 'Data dictionary function: Lists all views.';
COMMENT ON FUNCTION dd.columns IS 'Data dictionary function: Lists all columns';
COMMENT ON FUNCTION dd.functions IS 'Data dictionary function: Lists all functions';

"#
);



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
