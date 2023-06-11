# PostgreSQL Data Dictionary (pgdd)

The PostgreSQL Data Dictionary (`pgdd`) is an in-database solution to provide
introspection via standard SQL query syntax. This extension makes it easy to
provide a usable data dictionary to all users of a PostgreSQL database.

The extension is built on the Rust [pgrx framework](https://github.com/tcdi/pgrx) as of version 0.4.0.


## Compatibility

PgDD has been tested to work for PostgreSQL 11 through 15.


## Install from binary

Binaries are available for Ubuntu 22.04 (jammy) for AMD 64 architectures.
See [releases](https://github.com/rustprooflabs/pgdd/releases) for the full list of binaries.

Download and install for Postgres 15 on Ubuntu 22.04.

```bash
wget https://github.com/rustprooflabs/pgdd/releases/download/0.5.0/pgdd_0.5.0_focal_pg15_amd64.deb
sudo dpkg -i ./pgdd_0.5.0_jammy_pg15_amd64.deb
```

Create the extension in your database.

```sql
CREATE EXTENSION pgdd;
```

Check version.

```sql
SELECT extname, extversion
    FROM pg_catalog.pg_extension
    WHERE extname = 'pgdd'
;
```

```
┌─────────┬────────────┐
│ extname │ extversion │
╞═════════╪════════════╡
│ pgdd    │ 0.5.0      │
└─────────┴────────────┘
```



## Use Data Dictionary

Connect to your database using your favorite SQL client. This
could be psql, DBeaver, PgAdmin, or Python code... all you need
is a place to execute SQL code and see the results.

The main interaction with PgDD is through the views in the `dd` schema.

The `dd.views` query can be used to query the views within a database.

```sql
SELECT s_name, v_name, description
    FROM dd.views
;
```

```bash
┌────────┬───────────┬────────────────────────────────────────────────────────────────────┐
│ s_name │  v_name   │                            description                             │
╞════════╪═══════════╪════════════════════════════════════════════════════════════════════╡
│ dd     │ schemas   │ Data dictionary view: Lists schemas, excluding system schemas.     │
│ dd     │ tables    │ Data dictionary view: Lists tables, excluding system tables.       │
│ dd     │ views     │ Data dictionary view: Lists views, excluding system views.         │
│ dd     │ columns   │ Data dictionary view: Lists columns, excluding system columns.     │
│ dd     │ functions │ Data dictionary view: Lists functions, excluding system functions. │
└────────┴───────────┴────────────────────────────────────────────────────────────────────┘
```

> PgDD views wrap around functions with the same name and enforce `WHERE NOT system_object`. Query the functions to include `system_object` results.  e.g. `SELECT s_name, v_name FROM dd.views() WHERE system_object;`


### Schema

The highest level of querying provided by `pgdd` is at the schema level.
This provides counts of tables, views and functions along with the size on disk of the objects within the schema.

```sql
SELECT s_name, table_count, view_count, function_count,
        size_plus_indexes, description
    FROM dd.schemas
    WHERE s_name = 'dd';
```

Yields results such as this.

```bash
┌─[ RECORD 1 ]──────┬────────────────────────────────────────────────────────────────────────────────┐
│ s_name            │ dd                                                                             │
│ table_count       │ 3                                                                              │
│ view_count        │ 5                                                                              │
│ function_count    │ 6                                                                              │
│ size_plus_indexes │ 144 kB                                                                         │
│ description       │ Schema for Data Dictionary objects.  See https://github.com/rustprooflabs/pgdd │
└───────────────────┴────────────────────────────────────────────────────────────────────────────────┘
```


### Tables

The `dd.tables` view to examine tables created and populated by `pgbench`.


```sql
SELECT t_name, size_pretty, rows, bytes_per_row
    FROM dd.tables
    WHERE s_name = 'public'
        AND t_name LIKE 'pgbench%'
    ORDER BY size_bytes DESC;
```


```bash
┌──────────────────┬─────────────┬──────────┬───────────────┐
│      t_name      │ size_pretty │   rows   │ bytes_per_row │
╞══════════════════╪═════════════╪══════════╪═══════════════╡
│ pgbench_accounts │ 1281 MB     │ 10000000 │           134 │
│ pgbench_tellers  │ 80 kB       │     1000 │            82 │
│ pgbench_branches │ 40 kB       │      100 │           410 │
│ pgbench_history  │ 0 bytes     │        0 │             ¤ │
└──────────────────┴─────────────┴──────────┴───────────────┘
```



### Columns

```sql
SELECT source_type, s_name, t_name, c_name, data_type
    FROM dd.columns
    WHERE data_type LIKE 'int%'
;
```

```
┌─────────────┬────────┬─────────────┬────────────────┬───────────┐
│ source_type │ s_name │   t_name    │     c_name     │ data_type │
╞═════════════╪════════╪═════════════╪════════════════╪═══════════╡
│ table       │ dd     │ meta_schema │ meta_schema_id │ int8      │
│ table       │ dd     │ meta_table  │ meta_table_id  │ int8      │
│ table       │ dd     │ meta_column │ meta_column_id │ int8      │
│ view        │ dd     │ schemas     │ table_count    │ int8      │
│ view        │ dd     │ schemas     │ view_count     │ int8      │
│ view        │ dd     │ schemas     │ function_count │ int8      │
│ view        │ dd     │ schemas     │ size_bytes     │ int8      │
│ view        │ dd     │ tables      │ size_bytes     │ int8      │
│ view        │ dd     │ tables      │ rows           │ int8      │
│ view        │ dd     │ tables      │ bytes_per_row  │ int8      │
│ view        │ dd     │ views       │ rows           │ int8      │
│ view        │ dd     │ views       │ size_bytes     │ int8      │
│ view        │ dd     │ columns     │ position       │ int8      │
└─────────────┴────────┴─────────────┴────────────────┴───────────┘
```



### Functions


```sql
SELECT s_name, f_name, argument_data_types, result_data_types
    FROM dd.functions
;
```

### Partitioned tables

There are two views, ``dd.partition_parents`` and ``dd.partition_children`` to provide
partition-focused details.  Will display partitions for both
declarative partitions and inheritance based partitions



With the test data in this project for declarative partitions.


```sql
SELECT *
    FROM dd.partition_parents
    WHERE s_name = 'pgdd_test'
;
```

```
┌───────┬───────────┬────────┬────────────────┬────────────┬────────────┬─────────────┬────────────────────┬──────┬────────────────────┬───────────────────────────┬────────────────────┐
│  oid  │  s_name   │ t_name │ partition_type │ partitions │ size_bytes │ size_pretty │ size_per_partition │ rows │ rows_per_partition │ partitions_never_analyzed │ partitions_no_data │
╞═══════╪═══════════╪════════╪════════════════╪════════════╪════════════╪═════════════╪════════════════════╪══════╪════════════════════╪═══════════════════════════╪════════════════════╡
│ 25090 │ pgdd_test │ parent │ declarative    │          3 │      40960 │ 40 kB       │ 13 kB              │   15 │                  5 │                         0 │                  1 │
└───────┴───────────┴────────┴────────────────┴────────────┴────────────┴─────────────┴────────────────────┴──────┴────────────────────┴───────────────────────────┴────────────────────┘
```

Details for each child partition, including calculated percentages of the single
partition against the totals for the parent partition.



```sql
SELECT *
    FROM dd.partition_children
    WHERE s_name = 'pgdd_test'
;
```

```
┌───────┬───────────┬─────────────┬────────────┬──────────────────┬──────┬────────────┬─────────────┬───────────────────┬───────────────┬───────────────────────────┬────────────────────────────┐
│  oid  │  s_name   │   t_name    │ parent_oid │   parent_name    │ rows │ size_bytes │ size_pretty │ size_plus_indexes │ bytes_per_row │ percent_of_partition_rows │ percent_of_partition_bytes │
╞═══════╪═══════════╪═════════════╪════════════╪══════════════════╪══════╪════════════╪═════════════╪═══════════════════╪═══════════════╪═══════════════════════════╪════════════════════════════╡
│ 25095 │ pgdd_test │ child_0_10  │      25090 │ pgdd_test.parent │    9 │      16384 │ 16 kB       │ 32 kB             │          1820 │                    0.6000 │                     0.4000 │
│ 25109 │ pgdd_test │ child_20_30 │      25090 │ pgdd_test.parent │    0 │       8192 │ 8192 bytes  │ 16 kB             │             ¤ │                    0.0000 │                     0.2000 │
│ 25102 │ pgdd_test │ child_10_20 │      25090 │ pgdd_test.parent │    6 │      16384 │ 16 kB       │ 32 kB             │          2731 │                    0.4000 │                     0.4000 │
└───────┴───────────┴─────────────┴────────────┴──────────────────┴──────┴────────────┴─────────────┴───────────────────┴───────────────┴───────────────────────────┴────────────────────────────┘
```





## Database Permissions

Create Read-only group role to assign to users
that need access to query (read-only) the PgDD objects.

```sql
CREATE ROLE dd_read WITH NOLOGIN;
COMMENT ON ROLE dd_read IS 'Group role to grant read-only permissions to PgDD views.';

GRANT USAGE ON SCHEMA dd TO dd_read;
GRANT SELECT ON ALL TABLES IN SCHEMA dd TO dd_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA dd GRANT SELECT ON TABLES TO dd_read;
```

Access can now be granted to other users using:

```sql
GRANT dd_read TO <your_login_user>;
```

For read-write access.


```sql
CREATE ROLE dd_readwrite WITH NOLOGIN;
COMMENT ON ROLE dd_readwrite IS 'Group role to grant write permissions to PgDD objects.';

GRANT dd_read TO dd_readwrite;

GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA dd TO dd_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA dd GRANT INSERT, UPDATE, DELETE ON TABLES TO dd_readwrite;
```

This access can be granted using:

```sql
GRANT dd_readwrite TO <your_login_user>;
```



## Upgrade extension

Version 0.4.0 was a complete rewrite of the PgDD extension from a raw-SQL
extension to using the [pgrx framework](https://github.com/zombodb/pgrx).


Upgrading versions currently requires `DROP EXTENSION pgdd; CREATE EXTENSION pgdd;`
to recreate the extension.
This is unlikely to change until [pgrx #121 is resolved](https://github.com/tcdi/pgrx/issues/121).



If custom attributes were stored in the `dd` tables you will need to use
`pg_dump` to export the data and reload after recreating the extension
with pgrx.  If any of the three (3) queries below return a count > 0
this applies to you.


```sql
SELECT COUNT(*)
    FROM dd.meta_table
    WHERE s_name <> 'dd';
SELECT COUNT(*)
    FROM dd.meta_column
    WHERE s_name <> 'dd';
SELECT COUNT(*)
    FROM dd.meta_schema
    WHERE s_name <> 'dd';
```



The last raw SQL version (v0.3) is available to [download](https://raw.githubusercontent.com/rustprooflabs/pgdd/main/standalone/pgdd_v0_3.sql).  This version is no longer maintained and may or may not
work on future Postgres versions.



----


## PgDD UI

The [PgDD UI](https://github.com/rustprooflabs/pgdd-ui) project provides
a lightweight Flask interface to the the PgDD extension.

### Version checking

PgDD UI handles version checking with the Python `packaging` module so
PgDD versioning must conform to
[PEP 440](https://www.python.org/dev/peps/pep-0440/).


----

## Caveats

End user caveats:

* `pg_dump` ignores rows where `s_name = 'dd'`

Extension developer caveats:

* DDL changes made in `src/lib.rs` need to be in version-to-version upgrade (e.g. ``sql/pgdd-0.3.1--0.4.0.sql``).  This trick is not being used due to
[pgrx #121](https://github.com/zombodb/pgrx/issues/121). The pgrx functionality is exposed
via functions, and the functions are the core problem here.




