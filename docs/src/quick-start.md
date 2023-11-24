# Quick Start


## Install from binary

Binaries for supported Postgres versions are made available for each release.
See the individual release from the [releases](https://github.com/rustprooflabs/pgdd/releases)
page for the full list of binaries.
This currently includes binaries for two main LTS supported OS's using the AMD64 architecture.
The latest Ubuntu LTS (currently Jammy, 22.04) and the "PostGIS" image
(currently Debian 11).  The PostGIS image is provided to allow inclusion
in the [PgOSM Flex](https://pgosm-flex.com) project's Docker image. 

Download and install for PgDD 0.5.2 for Postgres 16 on Ubuntu 22.04.

```bash
wget https://github.com/rustprooflabs/pgdd/releases/download/0.5.2/pgdd_0.5.2_focal_pg16_amd64.deb
sudo dpkg -i ./pgdd_0.5.2_jammy_pg16_amd64.deb
```

Create the extension in your database.

```sql
CREATE EXTENSION pgdd;
```


## Database overview

```sql
SELECT * FROM dd.database;
```


```bash
┌─[ RECORD 1 ]────┬───────────┐
│ oid             │ 2853066   │
│ db_name         │ pgosm_dev │
│ db_size         │ 2325 MB   │
│ schema_count    │ 16        │
│ table_count     │ 107       │
│ size_in_tables  │ 2294 MB   │
│ view_count      │ 27        │
│ size_in_views   │ 11 MB     │
│ extension_count │ 8         │
└─────────────────┴───────────┘
```



## Views

Query `dd.views` within the `dd` schema (`s_name`) to see the other PgDD views
included.

```sql
SELECT s_name, v_name, description
    FROM dd.views
    WHERE s_name = 'dd'
;
```

```bash
┌────────┬────────────────────┬────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ s_name │       v_name       │                                            description                                             │
╞════════╪════════════════════╪════════════════════════════════════════════════════════════════════════════════════════════════════╡
│ dd     │ tables             │ Data dictionary view: Lists tables, excluding system tables.                                       │
│ dd     │ schemas            │ Data dictionary view: Lists schemas, excluding system schemas.                                     │
│ dd     │ views              │ Data dictionary view: Lists views, excluding system views.                                         │
│ dd     │ columns            │ Data dictionary view: Lists columns, excluding system columns.                                     │
│ dd     │ functions          │ Data dictionary view: Lists functions, excluding system functions.                                 │
│ dd     │ partition_parents  │ Data dictionary view: Lists parent partition tables with aggregate details about child partitions. │
│ dd     │ partition_children │ Data dictionary view: Lists individual partitions (children) of partitioned tables.                │
│ dd     │ database           │ Data dictionary view: Provides basic statistics for the current database.                          │
└────────┴────────────────────┴────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Query PgDD

See the [Query PgDD](./query.md) section for more examples.
