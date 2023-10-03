# Upgrade PgDD


Upgrading PgDD versions currently requires `DROP/CREATE` to upgrade.
This will not change until
[pgrx #121 is resolved](https://github.com/pgcentralfoundation/pgrx/issues/121).


The first thing to do is check if you have data stored in the `dd.meta_*`
tables.  Run the following query, if all three (3) rows return `row_count = 0`
you can simply drop and recreate the extension.


```sql
SELECT 'meta_table' AS src, COUNT(*) AS row_count
    FROM dd.meta_table
    WHERE s_name <> 'dd'
UNION
SELECT 'meta_column' AS src, COUNT(*) AS row_count
    FROM dd.meta_column
    WHERE s_name <> 'dd'
UNION
SELECT 'meta_schema' AS src, COUNT(*) AS row_count
    FROM dd.meta_schema
    WHERE s_name <> 'dd'
;
```


To drop and recreate the extension, run the following queries.

```sql
DROP EXTENSION pgdd;
CREATE EXTENSION pgdd;
```



## Upgrade with data in `dd` tables

If custom attributes are stored in the `dd` tables you will need to use
`pg_dump` to export the data and reload after recreating the extension
with pgrx.  If any of the three (3) queries below return a count > 0
this applies to you.

## Dump data from `dd` tables

Set the target database name in the `$DB_NAME` variable for later commands
to use.

```bash
export DB_NAME=pgosm_dev
```

Run `pg_dump` against the target database, drop and create the extension,
and reload the data to the `dd.meta_*` tables.

```bash
pg_dump -d $DB_NAME \
    --schema dd --data-only \
    -f ~/tmp/dd_upgrade_data.sql

psql -d $DB_NAME -c "DROP EXTENSION pgdd; CREATE EXTENSION pgdd;"
psql -d $DB_NAME -f ~/tmp/dd_upgrade_data.sql
```
