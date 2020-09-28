# PostgreSQL Data Dictionary (pgdd)

The PostgreSQL Data Dictionary (`pgdd`) is an in-database solution to provide
introspection via standard SQL query syntax.  This extension makes it easy to
provide a usable data dictionary to all users of a PostgreSQL database.

## Compatability

PgDD has been works for PostgreSQL 10 through 12.  PostgreSQL 13 support
is coming soon.

Docker images available on
[Docker Hub](https://hub.docker.com/r/rustprooflabs/pgdd).


## Install `pgdd` from source


One way to install `pgdd` is to install from 
source by downloading this repository.

### Prereqs

Ensure PostgreSQL dev tools are installed.

```bash
sudo apt install postgresql-server-dev-all libreadline-dev zlib1g-dev curl
```

[Install Rust](https://www.rust-lang.org/tools/install) and Pgx.

```bash
curl https://sh.rustup.rs -sSf | sh -s -- -y
cargo install cargo-pgx
```



### Clone repo

```bash
mkdir ~/git
cd ~/git
git clone https://github.com/rustprooflabs/pgdd.git
cd ~/git/pgdd
```

### Test deployment

Specify version, ``pg10``, ``pg11``, and ``pg12`` are currently supported.

```bash
cargo pgx run pg12
```



### Install on Server

```bash
cd ~/git/pgdd
sudo make install
```

### Create Extension in Database

```bash
sudo su - postgres
psql -d your_db
CREATE EXTENSION pgdd;
```

## Docker Image

PgDD can be deployed in a Docker image.  Uses [main Postgres image](https://hub.docker.com/_/postgres/) as starting point, see that
repo for full instructions on using the core Postgres functionality.

```
docker build -t rustprooflabs/pgdd .
```

Build with tag.

Run Postgres in Docker.

```
docker run --name test-pgdd12 -e POSTGRES_PASSWORD=mysecretpassword -p 6512:5432 -d rustprooflabs/pgdd
```

Connect via `psql` using `postgres` role, provide password from prior step
when prompted.

```
psql -h host_or_ip -p 6512 -U postgres 
```



## Database Permissions

Create Read-only group role to assign to users
that need access to query (read-only) the PgDD objects.

```
CREATE ROLE dd_read WITH NOLOGIN;
COMMENT ON ROLE dd_read IS 'Group role to grant read-only permissions to PgDD views.';

GRANT USAGE ON SCHEMA dd TO dd_read;
GRANT SELECT ON ALL TABLES IN SCHEMA dd TO dd_read;
ALTER DEFAULT PRIVILEGES IN SCHEMA dd GRANT SELECT ON TABLES TO dd_read;
```

Access can now be granted to other users using:

```
GRANT dd_read TO <your_login_user>;
```

For read-write access.


```
CREATE ROLE dd_readwrite WITH NOLOGIN;
COMMENT ON ROLE dd_readwrite IS 'Group role to grant write permissions to PgDD objects.';

GRANT dd_read TO dd_readwrite;

GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA dd TO dd_readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA dd GRANT INSERT, UPDATE, DELETE ON TABLES TO dd_readwrite;
```

This access can be granted using:
 
```
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

