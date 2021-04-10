# PostgreSQL Data Dictionary (pgdd)

The PostgreSQL Data Dictionary (`pgdd`) is an in-database solution to provide
introspection via standard SQL query syntax. This extension makes it easy to
provide a usable data dictionary to all users of a PostgreSQL database.

The extension is built on the Rust [pgx framework](https://github.com/zombodb/pgx) as of version 0.4.0.


## Compatibility

PgDD has been tested to work for PostgreSQL 10 through 13.


## Upgrading from <= v0.3

Version 0.4.0 was a complete rewrite of the PgDD extension in a new language.
Care has been taken to provide a smooth upgrade experience but
**do not upgrade without testing the upgrade on a test server!**


Versions 0.3 and prior were written as a raw SQL extension, but that method lacked ability to provide version-specific functionality (such as generated columns, procedures, etc.).

The last raw SQL version is still available to [download](https://raw.githubusercontent.com/rustprooflabs/pgdd/main/standalone/pgdd_v0_3.sql).  This version is no longer maintained and may or may not
work on future Postgres versions.



## Install from binary

Download the appropriate binary.

```bash
wget https://github.com/rustprooflabs/pgdd/raw/dev/standalone/pgdd_0.4.0-dev_focal_pg13_amd64.deb
```

Install.


```bash
sudo dpkg -i ./pgdd_0.4.0-dev_focal_pg13_amd64.deb
```

In your database.


```sql
CREATE EXTENSION pgdd;
```


## Update

As new [releases](https://github.com/rustprooflabs/pgdd/releases) are
available, download the new binary and install using the above instructions.


Then, in your database.

```sql
ALTER EXTENSION pgdd UPDATE;
```

----

**WARNING**

Postgres sessions started before the`UPDATE EXTENSION` command will
continue to see the old version of PgDD. New sessions will see the
updated extension.

If the following query returns true, disconnect and reconnect to
the database with PgDD to use the latest installed version.


```sql
SELECT CASE WHEN version <> dd.version() THEN True
        ELSE False
        END AS pgdd_needs_reload
    FROM pg_catalog.pg_available_extension_versions
    WHERE name = 'pgdd' AND installed
;
```


----


## Use Data Dictionary

Connect to your database using your favorite SQL client. This
could be psql, DBeaver, PgAdmin, or Python code... all you need
is a place to execute SQL code and see the results.

The main interaction with PgDD is through the views in the `dd` schema.
The `dd.views` query can be used to query the views within a database.

```sql
SELECT s_name, v_name, description
    FROM dd.views
    WHERE s_name = 'dd';
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

> The views wrap around functions with the same name and enforce `WHERE NOT system_object`. Query the functions to include system_objects in the results.


### Schema

The highest level of querying provided by `pgdd` is at the schema level.
This provides counts of tables, views and functions along with the size on disk of the objects within the schema.

```sql
SELECT *
    FROM dd.schemas
    WHERE s_name = 'dd';
```

Yields results such as this.

```bash
┌─[ RECORD 1 ]──────┬────────────────────────────────────────────────────────────┐
│ s_name            │ dd                                                         │
│ owner             │ postgres                                                   │
│ data_source       │ Manually maintained                                        │
│ sensitive         │ f                                                          │
│ description       │ Data Dictionary from https://github.com/rustprooflabs/pgdd │
│ system_object     │ f                                                          │
│ table_count       │ 3                                                          │
│ view_count        │ 5                                                          │
│ function_count    │ 7                                                          │
│ size_pretty       │ 48 kB                                                      │
│ size_plus_indexes │ 144 kB                                                     │
│ size_bytes        │ 49152                                                      │
└───────────────────┴────────────────────────────────────────────────────────────┘
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

Returns:

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
SELECT * FROM dd.columns;
```



### Functions


```sql
SELECT *
    FROM dd.fuctions;
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



## PgDD UI

The [PgDD UI](https://github.com/rustprooflabs/pgdd-ui) project provides
a lightweight Flask interface to the the PgDD extension.

### Version checking

PgDD UI handles version checking with the Python `packaging` module so
PgDD versioning must conform to
[PEP 440](https://www.python.org/dev/peps/pep-0440/).


## Caveats

* `pg_dump` ignores rows where `s_name = 'dd'`


