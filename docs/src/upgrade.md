# Upgrade PgDD


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

