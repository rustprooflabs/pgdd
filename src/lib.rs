use pgrx::prelude::*;

pgrx::pg_module_magic!();


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
fn schemas() -> Result<
    TableIterator<
        'static,
        (
            name!(s_name,Option<String>),
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
        ),
    >,
    spi::Error,
> {
    let query = include_str!("sql/function_query/schemas-all.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let tup_table = client.select(query, None, &[])?;

        for row in tup_table {
            let s_name = row["s_name"].value::<String>()?;
            let owner = row["owner"].value::<String>()?;
            let data_source = row["data_source"].value::<String>()?;
            let sensitive = row["sensitive"].value::<bool>()?;
            let description = row["description"].value::<String>()?;
            let system_object = row["system_object"].value::<bool>()?;
            let table_count = row["table_count"].value::<i64>()?;
            let view_count = row["view_count"].value::<i64>()?;
            let function_count = row["function_count"].value::<i64>()?;
            let size_pretty = row["size_pretty"].value::<String>()?;
            let size_plus_indexes = row["size_plus_indexes"].value::<String>()?;
            let size_bytes = row["size_bytes"].value::<i64>()?;
            let size_plus_indexes_bytes = row["size_plus_indexes_bytes"].value::<i64>()?;
            results.push((s_name, owner, data_source, sensitive, description,
                system_object, table_count, view_count, function_count,
                size_pretty, size_plus_indexes, size_bytes, size_plus_indexes_bytes
            ));
        }
        Ok(TableIterator::new(results))
    })
}


#[pg_extern]
fn columns() -> Result<
TableIterator<
    'static,
    (

        name!(s_name, Option<String>),
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
        name!(generated_column, Option<bool>)
    ),
    >,
    spi::Error,
> {
    //#[cfg(any(feature="pg11"))]
    //let query = include_str!("sql/function_query/columns-pre-12.sql");
    #[cfg(any(feature="pg13", feature="pg14", feature="pg15", feature="pg16", feature="pg17"))]
    let query = include_str!("sql/function_query/columns-12.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let mut tup_table = client.select(query, None, &[])?;

        while let Some(row) = tup_table.next() {
            let s_name = row["s_name"].value::<String>()?;
            let source_type = row["source_type"].value::<String>()?;
            let t_name = row["t_name"].value::<String>()?;
            let c_name = row["c_name"].value::<String>()?;
            let data_type = row["data_type"].value::<String>()?;
            let position = row["position"].value::<i64>()?;
            let description = row["description"].value::<String>()?;
            let data_source = row["data_source"].value::<String>()?;
            let sensitive = row["sensitive"].value::<bool>()?;
            let system_object = row["system_object"].value::<bool>()?;
            let default_value = row["default_value"].value::<String>()?;
            let generated_column = row["generated_column"].value::<bool>()?;

            results.push((s_name, source_type, t_name, c_name, data_type,
                position, description, data_source, sensitive,
                system_object, default_value, generated_column
            ));
        }
        Ok(TableIterator::new(results.into_iter()))
    })
}


#[pg_extern]
fn functions() -> Result<
TableIterator<
    'static,
    (
        name!(s_name, Option<String>),
        name!(f_name, Option<String>),
        name!(result_data_types, Option<String>),
        name!(argument_data_types, Option<String>),
        name!(owned_by, Option<String>),
        name!(proc_security, Option<String>),
        name!(access_privileges, Option<String>),
        name!(proc_language, Option<String>),
        name!(source_code, Option<String>),
        name!(description, Option<String>),
        name!(system_object, Option<bool>)
    ),
    >,
    spi::Error,
> {
    let query = include_str!("sql/function_query/functions-all.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let mut tup_table = client.select(query, None, &[])?;

        while let Some(row) = tup_table.next() {
            let s_name = row["s_name"].value::<String>()?;
            let f_name = row["f_name"].value::<String>()?;
            let result_data_types = row["result_data_types"].value::<String>()?;
            let argument_data_types = row["argument_data_types"].value::<String>()?;
            let owned_by = row["owned_by"].value::<String>()?;
            let proc_security = row["proc_security"].value::<String>()?;
            let access_privileges = row["access_privileges"].value::<String>()?;
            let proc_language = row["proc_language"].value::<String>()?;
            let source_code = row["source_code"].value::<String>()?;
            let description = row["description"].value::<String>()?;
            let system_object = row["system_object"].value::<bool>()?;

            results.push((s_name, f_name, result_data_types, argument_data_types,
                owned_by, proc_security, access_privileges, proc_language,
                source_code, description, system_object
            ));
        }
        Ok(TableIterator::new(results.into_iter()))
    })
}


#[pg_extern]
fn tables() -> Result<
TableIterator<
    'static,
    (
        name!(s_name, Option<String>),
        name!(t_name, Option<String>),
        name!(data_type, Option<String>),
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
        name!(oid, Option<pg_sys::Oid>)
),
    >,
    spi::Error,
> {
    let query = include_str!("sql/function_query/tables-all.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let mut tup_table = client.select(query, None, &[])?;

        while let Some(row) = tup_table.next() {
            let s_name = row["s_name"].value::<String>()?;
            let t_name = row["t_name"].value::<String>()?;
            let data_type = row["data_type"].value::<String>()?;
            let owned_by = row["owned_by"].value::<String>()?;
            let size_pretty = row["size_pretty"].value::<String>()?;
            let size_bytes = row["size_bytes"].value::<i64>()?;
            let rows = row["rows"].value::<i64>()?;
            let bytes_per_row = row["bytes_per_row"].value::<i64>()?;
            let size_plus_indexes_bytes = row["size_plus_indexes_bytes"].value::<i64>()?;
            let size_plus_indexes = row["size_plus_indexes"].value::<String>()?;
            let description = row["description"].value::<String>()?;
            let system_object = row["system_object"].value::<bool>()?;
            let data_source = row["data_source"].value::<String>()?;
            let sensitive = row["sensitive"].value::<bool>()?;
            let oid = row["oid"].value::<pg_sys::Oid>()?;

            results.push((s_name, t_name, data_type, owned_by, size_pretty,
                size_bytes, rows, bytes_per_row, size_plus_indexes_bytes,
                size_plus_indexes, description, system_object, data_source,
                sensitive, oid
            ));
        }
        Ok(TableIterator::new(results.into_iter()))
    })
}


#[pg_extern]
fn views() -> Result<
TableIterator<
    'static,
    (
        name!(s_name, Option<String>),
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
        name!(oid, Option<pg_sys::Oid>)),
    >,
    spi::Error,
> {
    let query = include_str!("sql/function_query/views-all.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let mut tup_table = client.select(query, None, &[])?;

        while let Some(row) = tup_table.next() {
            let s_name = row["s_name"].value::<String>()?;
            let v_name = row["v_name"].value::<String>()?;
            let view_type = row["view_type"].value::<String>()?;
            let owned_by = row["owned_by"].value::<String>()?;
            let rows = row["rows"].value::<i64>()?;
            let size_pretty = row["size_pretty"].value::<String>()?;
            let size_bytes = row["size_bytes"].value::<i64>()?;
            let size_plus_indexes = row["size_plus_indexes"].value::<String>()?;
            let size_plus_indexes_bytes = row["size_plus_indexes_bytes"].value::<i64>()?;
            let description = row["description"].value::<String>()?;
            let system_object = row["system_object"].value::<bool>()?;
            let oid = row["oid"].value::<pg_sys::Oid>()?;

            results.push((s_name, v_name, view_type, owned_by, rows, size_pretty,
                size_bytes, size_plus_indexes, size_plus_indexes_bytes,
                description, system_object, oid
            ));
        }
        Ok(TableIterator::new(results.into_iter()))
    })
}



#[pg_extern]
fn partition_parents() -> Result<
TableIterator<
    'static,
    (
        name!(oid, Option<pg_sys::Oid>),
        name!(s_name, Option<String>),
        name!(t_name, Option<String>),
        name!(partition_type, Option<String>),
        name!(partitions, Option<i64>)),
    >,
    spi::Error,
> {
    let query = include_str!("sql/function_query/partition-parent.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let mut tup_table = client.select(query, None, &[])?;

        while let Some(row) = tup_table.next() {
            let oid = row["oid"].value::<pg_sys::Oid>()?;
            let s_name = row["s_name"].value::<String>()?;
            let t_name = row["t_name"].value::<String>()?;
            let partition_type = row["partition_type"].value::<String>()?;
            let partitions = row["partitions"].value::<i64>()?;

            results.push((oid, s_name, t_name, partition_type, partitions
            ));
        }
        Ok(TableIterator::new(results.into_iter()))
    })
}


#[pg_extern]
fn partition_children() -> Result<
TableIterator<
    'static,
    (
        name!(oid, Option<pg_sys::Oid>),
        name!(s_name, Option<String>),
        name!(t_name, Option<String>),
        name!(parent_oid, Option<pg_sys::Oid>),
        name!(parent_name, Option<String>),
        name!(declarative_partition, Option<bool>),
        name!(partition_expression, Option<String>)),
    >,
    spi::Error,
> {
    let query = include_str!("sql/function_query/partition-child.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let mut tup_table = client.select(query, None, &[])?;

        while let Some(row) = tup_table.next() {
            let oid = row["oid"].value::<pg_sys::Oid>()?;
            let s_name = row["s_name"].value::<String>()?;
            let t_name = row["t_name"].value::<String>()?;
            let parent_oid = row["parent_oid"].value::<pg_sys::Oid>()?;
            let parent_name = row["parent_name"].value::<String>()?;
            let declarative_partition = row["declarative_partition"].value::<bool>()?;
            let partition_expression = row["partition_expression"].value::<String>()?;

            results.push((oid, s_name, t_name, parent_oid, parent_name,
                declarative_partition, partition_expression
            ));
        }
        Ok(TableIterator::new(results.into_iter()))
    })
}


#[pg_extern]
fn database() -> Result<
TableIterator<
    'static,
    (
        name!(oid, Option<pg_sys::Oid>),
        name!(db_name, Option<String>),
        name!(db_size, Option<String>),
        name!(schema_count, Option<i64>),
        name!(table_count, Option<i64>),
        name!(size_in_tables, Option<String>),
        name!(view_count, Option<i64>),
        name!(size_in_views, Option<String>),
        name!(extension_count, Option<i64>)),
    >,
    spi::Error,
> {
    let query = include_str!("sql/function_query/database-all.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let mut tup_table = client.select(query, None, &[])?;

        while let Some(row) = tup_table.next() {
            let oid = row["oid"].value::<pg_sys::Oid>()?;
            let db_name = row["db_name"].value::<String>()?;
            let db_size = row["db_size"].value::<String>()?;
            let schema_count = row["schema_count"].value::<i64>()?;
            let table_count = row["table_count"].value::<i64>()?;
            let size_in_tables = row["size_in_tables"].value::<String>()?;
            let view_count = row["view_count"].value::<i64>()?;
            let size_in_views = row["size_in_views"].value::<String>()?;
            let extension_count = row["extension_count"].value::<i64>()?;

            results.push((oid, db_name, db_size, schema_count, table_count,
                size_in_tables, view_count, size_in_views, extension_count
            ));
        }
        Ok(TableIterator::new(results.into_iter()))
    })
}


#[pg_extern]
fn index() -> Result<
TableIterator<
    'static,
    (
        name!(oid, Option<pg_sys::Oid>),
        name!(s_name, Option<String>),
        name!(t_name, Option<String>),
        name!(i_name, Option<String>),
        name!(key_columns, Option<i16>),
        name!(total_columns, Option<i16>),
        name!(primary_key, Option<bool>),
        name!(unique_index, Option<bool>),
        name!(valid_index, Option<bool>),
        name!(partial_index, Option<bool>),
        name!(rows_indexed, Option<f32>),
        name!(index_size, Option<String>),
        name!(index_size_bytes, Option<i64>),
        name!(system_object, Option<bool>)
        ),
    >,
    spi::Error,
> {
    let query = include_str!("sql/function_query/index-all.sql");

    Spi::connect(|client| {
        let mut results = Vec::new();
        let mut tup_table = client.select(query, None, &[])?;

        while let Some(row) = tup_table.next() {
            let oid = row["oid"].value::<pg_sys::Oid>()?;
            let s_name = row["s_name"].value::<String>()?;
            let t_name = row["t_name"].value::<String>()?;
            let i_name = row["i_name"].value::<String>()?;
            let key_columns = row["key_columns"].value::<i16>()?;
            let total_columns = row["total_columns"].value::<i16>()?;
            let primary_key = row["primary_key"].value::<bool>()?;
            let unique_index = row["unique_index"].value::<bool>()?;
            let valid_index = row["valid_index"].value::<bool>()?;
            let partial_index = row["partial_index"].value::<bool>()?;
            let rows_indexed = row["rows_indexed"].value::<f32>()?;
            let index_size = row["index_size"].value::<String>()?;
            let index_size_bytes = row["index_size_bytes"].value::<i64>()?;
            let system_object = row["system_object"].value::<bool>()?;

            results.push((oid, s_name, t_name, i_name, key_columns,
                total_columns, primary_key, unique_index, valid_index,
                partial_index, rows_indexed, index_size, index_size_bytes,
                system_object
            ));
        }
        Ok(TableIterator::new(results.into_iter()))
    })
}



#[pg_extern]
fn about() -> &'static str {
    "PgDD: PostgreSQL Data Dictionary extension.  See https://github.com/rustprooflabs/pgdd for details!"
}


// extension_sql_file!("sql/create_extension_views_all.sql",
//     name = "views"
// );


// extension_sql_file!("sql/comments_all.sql",
//     finalize
// );

