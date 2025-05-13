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


// Using a feature flag to enable for all current version as a reminder to self we can do this.
#[cfg(any(feature="pg13", feature="pg14", feature="pg15", feature="pg16", feature="pg17"))]
extension_sql_file!("sql/function_query/columns_12.sql",
    requires = ["create_extension_tables_all"]
);


extension_sql_file!("sql/function_query/functions_all.sql",
    requires = ["create_extension_tables_all"]
);

extension_sql_file!("sql/function_query/index_all.sql",
    requires = ["create_extension_tables_all"]
);

extension_sql_file!("sql/function_query/partition_parent_all.sql",
    requires = ["create_extension_tables_all"]
);

extension_sql_file!("sql/function_query/partition_child_all.sql",
    requires = ["create_extension_tables_all"]
);

extension_sql_file!("sql/function_query/schemas_all.sql",
    requires = ["create_extension_tables_all"]
);

extension_sql_file!("sql/function_query/tables_all.sql",
    requires = ["create_extension_tables_all"]
);

extension_sql_file!("sql/function_query/views_all.sql",
    requires = ["create_extension_tables_all"]
);


extension_sql_file!("sql/function_query/partition_cross_dependencies.sql",
    requires = ["partition_parent_all", "partition_child_all", "tables_all"]
);


extension_sql_file!("sql/function_query/database_all.sql",
    requires = ["tables_all", "views_all", "schemas_all"]
);



#[pg_extern]
fn about() -> &'static str {
    "PgDD: PostgreSQL Data Dictionary extension.  See https://github.com/rustprooflabs/pgdd for details!"
}


extension_sql_file!("sql/comments_all.sql",
    finalize
);

