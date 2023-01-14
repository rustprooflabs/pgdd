use pgx::prelude::*;

pgx::pg_module_magic!();


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
) -> Result<TableIterator<'static, (
                             name!(s_name, Option<String>),
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
                             name!(size_bytes, Option<i64>),
                             name!(size_plus_indexes_bytes, Option<i64>)
                            ),>, spi::Error,> {
    let query = include_str!("sql/function_query/schemas-all.sql");
    let mut results = Vec::new();

    Spi::connect(|client| {
        client
            .select(query, None, None)?
            .map(|row| (row["s_name"].value(),
                        row["owner"].value(),
                        row["data_source"].value(),
                        row["sensitive"].value(),
                        row["description"].value(),
                        row["system_object"].value(),
                        row["table_count"].value(),
                        row["view_count"].value(),
                        row["function_count"].value(),
                        row["size_pretty"].value(),
                        row["size_plus_indexes"].value(),
                        row["size_bytes"].value(),
                        row["size_plus_indexes_bytes"].value()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });
    TableIterator::new(results.into_iter())
}



#[pg_extern]
fn columns(
) -> TableIterator<'static, (name!(s_name, Option<String>),
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
    #[cfg(any(feature = "pg12", feature="pg13", feature="pg14", feature="pg15"))]
    let query = include_str!("sql/function_query/columns-12.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row["s_name"].value(),
                        row["source_type"].value(),
                        row["t_name"].value(),
                        row["c_name"].value(),
                        row["data_type"].value(),
                        row["position"].value(),
                        row["description"].value(),
                        row["data_source"].value(),
                        row["sensitive"].value(),
                        row["system_object"].value(),
                        row["default_value"].value(),
                        row["generated_column"].value()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });
    TableIterator::new(results.into_iter())
}


#[pg_extern]
fn functions(
) -> TableIterator<'static, (name!(s_name, Option<String>),
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
            .map(|row| (row["s_name"].value(),
                        row["f_name"].value(),
                        row["result_data_types"].value(),
                        row["argument_data_types"].value(),
                        row["owned_by"].value(),
                        row["proc_security"].value(),
                        row["access_privileges"].value(),
                        row["proc_language"].value(),
                        row["source_code"].value(),
                        row["description"].value(),
                        row["system_object"].value()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });
    TableIterator::new(results.into_iter())
}



#[pg_extern]
fn tables(
) -> TableIterator<'static, (name!(s_name, Option<String>),
                             name!(t_name, Option<String>),
                             name!(type, Option<String>),
                             name!(owned_by, Option<String>),
                             name!(size_pretty, Option<String>),
                             name!(size_bytes, Option<i64>),
                             name!(rows, Option<i64>),
                             name!(bytes_per_row, Option<i64>),
                             name!(size_plus_indexes_bytes, Option<i64>),
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
            .map(|row| (row["s_name"].value(),
                        row["t_name"].value(),
                        row["type"].value(),
                        row["owned_by"].value(),
                        row["size_pretty"].value(),
                        row["size_bytes"].value(),
                        row["rows"].value(),
                        row["bytes_per_row"].value(),
                        row["size_plus_indexes_bytes"].value(),
                        row["size_plus_indexes"].value(),
                        row["description"].value(),
                        row["system_object"].value(),
                        row["data_source"].value(),
                        row["sensitive"].value(),
                        row["oid"].value()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });
    TableIterator::new(results.into_iter())
}



#[pg_extern]
fn views(
) -> TableIterator<'static, (name!(s_name, Option<String>),
                             name!(v_name, Option<String>),
                             name!(view_type, Option<String>),
                             name!(owned_by, Option<String>),
                             name!(rows, Option<i64>),
                             name!(size_pretty, Option<String>),
                             name!(size_bytes, Option<i64>),
                             name!(size_plus_indexes, Option<String>),
                             name!(size_plus_indexes_bytes, Option<i64>),
                             name!(description, Option<String>),
                             name!(system_object, Option<bool>),
                             name!(oid, Option<i64>))>
{
    let query = include_str!("sql/function_query/views-all.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row["s_name"].value(),
                        row["v_name"].value(),
                        row["view_type"].value(),
                        row["owned_by"].value(),
                        row["rows"].value(),
                        row["size_pretty"].value(),
                        row["size_bytes"].value(),
                        row["size_plus_indexes"].value(),
                        row["size_plus_indexes_bytes"].value(),
                        row["description"].value(),
                        row["system_object"].value(),
                        row["oid"].value()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });
    TableIterator::new(results.into_iter())
}



#[pg_extern]
fn partition_parents(
) -> TableIterator<'static, (name!(oid, Option<i64>),
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
            .map(|row| (row["oid"].value(),
                        row["s_name"].value(),
                        row["t_name"].value(),
                        row["partition_type"].value(),
                        row["partitions"].value()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });
    TableIterator::new(results.into_iter())
}


#[pg_extern]
fn partition_children(
) -> TableIterator<'static, (name!(oid, Option<i64>),
                             name!(s_name, Option<String>),
                             name!(t_name, Option<String>),
                             name!(parent_oid, Option<i64>),
                             name!(parent_name, Option<String>),
                             name!(declarative_partition, Option<bool>),
                             name!(partition_expression, Option<String>))>
{
    let query = include_str!("sql/function_query/partition-child.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row["oid"].value(),
                        row["s_name"].value(),
                        row["t_name"].value(),
                        row["parent_oid"].value(),
                        row["parent_name"].value(),
                        row["declarative_partition"].value(),
                        row["partition_expression"].value()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });
    TableIterator::new(results.into_iter())
}


#[pg_extern]
fn database(
) -> TableIterator<'static, (name!(oid, Option<i64>),
                             name!(db_name, Option<String>),
                             name!(db_size, Option<String>),
                             name!(schema_count, Option<i64>),
                             name!(table_count, Option<i64>),
                             name!(size_in_tables, Option<String>),
                             name!(view_count, Option<i64>),
                             name!(size_in_views, Option<String>),
                             name!(extension_count, Option<i64>))>
{
    let query = include_str!("sql/function_query/database-all.sql");

    let mut results = Vec::new();
    Spi::connect(|client| {
        client
            .select(query, None, None)
            .map(|row| (row["oid"].value(),
                        row["db_name"].value(),
                        row["db_size"].value(),
                        row["schema_count"].value(),
                        row["table_count"].value(),
                        row["size_in_tables"].value(),
                        row["view_count"].value(),
                        row["size_in_views"].value(),
                        row["extension_count"].value()
                        ))
            .for_each(|tuple| results.push(tuple));
        Ok(Some(()))
    });
    TableIterator::new(results.into_iter())
}


#[pg_extern]
fn about() -> &'static str {
    "PgDD: PostgreSQL Data Dictionary extension.  See https://github.com/rustprooflabs/pgdd for details!"
}


extension_sql_file!("sql/create_extension_views_all.sql",
    name = "views"
);

extension_sql_file!("sql/comments_all.sql",
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
