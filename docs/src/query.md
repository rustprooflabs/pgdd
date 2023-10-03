# Query PgDD

Connect to your database using your favorite SQL client. This
could be psql, DBeaver, PgAdmin, or Python code... all you need
is a place to execute SQL code and see the results.

The main interaction with PgDD is through the views in the `dd` schema.

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





The `dd.views` query can be used to query the views within a database.

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


