use pgx::*;

pg_module_magic!();

// NOTE: DDL must be defined here to be created by `CREATE EXTENSION pgdd;`
//    Changes to DDL must be made BOTH here and
//    in the associated version-to-version upgrade script
//
// FIXME:  WATCH FOR WHEN THIS COMMENT BECOMES OBSOLETE!  ^^^

extension_sql_file!("sql/create_extension_tables_all.sql",
    bootstrap
);


extension_sql_file!("sql/load_default_data.sql",
    requires = ["create_extension_tables_all"]
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
    let query = include_str!("sql/function_query/schemas-all.sql");

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
    let query = include_str!("sql/function_query/columns-pre-12.sql");
    #[cfg(any(feature = "pg12", feature="pg13", feature="pg14"))]
    let query = include_str!("sql/function_query/columns-12.sql");

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
    let query = include_str!("sql/function_query/functions-all.sql");

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
                                      name!(sensitive, Option<bool>),
                                      name!(oid, Option<i64>)
                                      )>
{
    let query = include_str!("sql/function_query/tables-all.sql");

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
                        row.by_ordinal(13).unwrap().value::<bool>(),
                        row.by_ordinal(14).unwrap().value::<i64>()
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
    let query = include_str!("sql/function_query/views-all.sql");

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
fn partition_parent(
) -> impl std::iter::Iterator<Item = (name!(oid, Option<i64>),
                                      name!(s_name, Option<String>),
                                      name!(t_name, Option<String>),
                                      name!(partition_type, Option<String>),
                                      name!(partitions, Option<i64>))>
{
    let query = include_str!("sql/function_query/partition-parent.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row.by_ordinal(1).unwrap().value::<i64>(),
                        row.by_ordinal(2).unwrap().value::<String>(),
                        row.by_ordinal(3).unwrap().value::<String>(),
                        row.by_ordinal(4).unwrap().value::<String>(),
                        row.by_ordinal(5).unwrap().value::<i64>()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });

    results.into_iter()
}


#[pg_extern]
fn partition_child(
) -> impl std::iter::Iterator<Item = (name!(oid, Option<i64>),
                                      name!(s_name, Option<String>),
                                      name!(t_name, Option<String>),
                                      name!(parent_oid, Option<i64>),
                                      name!(parent_name, Option<String>),
                                      name!(relispartition, Option<bool>),
                                      name!(relkind, Option<String>),
                                      name!(partition_expression, Option<String>))>
{
    let query = include_str!("sql/function_query/partition-child.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row.by_ordinal(1).unwrap().value::<i64>(),
                        row.by_ordinal(2).unwrap().value::<String>(),
                        row.by_ordinal(3).unwrap().value::<String>(),
                        row.by_ordinal(4).unwrap().value::<i64>(),
                        row.by_ordinal(5).unwrap().value::<String>(),
                        row.by_ordinal(6).unwrap().value::<bool>(),
                        row.by_ordinal(7).unwrap().value::<String>(),
                        row.by_ordinal(8).unwrap().value::<String>()
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


extension_sql_file!("sql/create_extension_views_all.sql",
    finalize
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
