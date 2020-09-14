use pgx::*;

pg_module_magic!();



extension_sql!(
    r#"
CREATE SCHEMA dd;
COMMENT ON SCHEMA dd IS 'Data Dictionary from https://github.com/rustprooflabs/pgdd';
----------------------------------------

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


CREATE VIEW dd.schemas AS 
WITH s AS (
SELECT n.oid, n.nspname AS s_name,
        pg_catalog.pg_get_userbyid(n.nspowner) AS owner,
        ms.data_source,
        ms.sensitive,
        pg_catalog.obj_description(n.oid, 'pg_namespace') AS description
    FROM pg_catalog.pg_namespace n
    LEFT JOIN dd.meta_schema ms 
        ON n.nspname = ms.s_name
    
    WHERE n.nspname !~ '^pg_' 
        AND n.nspname NOT IN ('pg_catalog', 'information_schema')
)
SELECT s.s_name, s.owner, s.data_source, s.sensitive, 
        s.description,
        COALESCE(COUNT(c.*), 0)::INT AS table_count,
        pg_catalog.pg_size_pretty(SUM(pg_catalog.pg_table_size(c.oid))) AS size_pretty,
        SUM(pg_catalog.pg_table_size(c.oid)) AS size_bytes
    FROM s
    LEFT JOIN pg_catalog.pg_class c 
        ON s.oid = c.relnamespace AND c.relkind IN ('r','p')
    GROUP BY s.s_name, s.owner, s.data_source, s.sensitive, s.description
;
-- Add more SQL here.
"#
);



#[pg_extern]
fn hello_pgdd_rust() -> &'static str {
    "Hello, pgdd_rust"
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
