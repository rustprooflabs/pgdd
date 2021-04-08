# PostgreSQL Data Dictionary (pgdd)

The PostgreSQL Data Dictionary (`pgdd`) is an in-database solution to provide
introspection via standard SQL query syntax.  This extension makes it easy to
provide a usable data dictionary to all users of a PostgreSQL database.

Originally written in raw SQL, the extension is converting to the Rust
[pgx framework](https://github.com/zombodb/pgx).


## Compatibility

PgDD has been tested to work for PostgreSQL 10 through 13.

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



## Use Data Dictionary

Connect to your database using your favorite SQL client.  This
could be psql, DBeaver, PgAdmin, or Python code... all you need
is a place to execute SQL code!

### Schema

The highest level of querying provided by `pgdd` is at the schema level.

```sql
SELECT *
    FROM dd.schemas
    WHERE s_name = 'dd';
```

Yields results

```bash
Name       |Value                                                     |
-----------|----------------------------------------------------------|
s_name     |dd                                                        |
owner      |rpl_db_admin                                              |
data_source|Manually maintained                                       |
sensitive  |false                                                     |
description|Data Dictionary from https://github.com/rustprooflabs/pgdd|
table_count|3                                                         |
size_pretty|48 kB                                                     |
size_bytes |49152                                                     |
```

### Tables

The query:

```sql
SELECT t_name, size_pretty, description
    FROM dd.tables
    WHERE s_name = 'dd';
```

Yields results

```bash
t_name     |size_pretty|description                                                   |
-----------|-----------|--------------------------------------------------------------|
meta_schema|16 kB      |User definable meta-data at the schema level.                 |
meta_table |16 kB      |User definable meta-data at the schema + table level.         |
meta_column|16 kB      |User definable meta-data at the schema + table + column level.|
```

A bit more interesting, with data initialized from `pgbench` and ran for a short while.


```sql
SELECT t_name, size_pretty, rows, bytes_per_row
    FROM dd.tables
    WHERE s_name IN ('public')
    ORDER BY size_bytes DESC;
```

Returns:

```bash
t_name          |size_pretty|rows   |bytes_per_row     |
----------------|-----------|-------|------------------|
pgbench_accounts|130 MB     |1000000|         136.68352|
pgbench_history |4072 kB    |  77379|53.887075304669224|
pgbench_branches|144 kB     |     10|           14745.6|
pgbench_tellers |144 kB     |    100|           1474.56|
```

### Columns

```sql
SELECT * FROM dd.columns;
```

### Views

```sql
SELECT *
    FROM dd.views
    WHERE s_name = 'dd';
```

Returns

```bash
v_name   |description                                              |
---------|---------------------------------------------------------|
schemas  |Data dictionary view:  Lists schemas                     |
columns  |Data dictionary view:  Lists columns in tables           |
tables   |Data dictionary view:  Lists tables                      |
functions|Data dictionary view:  Lists functions (procedures)      |
views    |Data dictionary view:  Lists views and materialized views|
```


### Functions


```sql
SELECT *
    FROM dd.fuctions;
```

## PgDD UI

The [PgDD UI](https://github.com/rustprooflabs/pgdd-ui) project provides
a lightweight Flask interface to the the PgDD extension.

### Version checking

PgDD UI handles version checking with the Python `packaging` module so
PgDD versioning must conform to
[PEP 440](https://www.python.org/dev/peps/pep-0440/).

