# Developer Notes


## Drop/recreate for upgrade

If [pgrx #121](https://github.com/pgcentralfoundation/pgrx/issues/121)
is resolved, the need to `DROP EXTENSION pgdd; CREATE EXTENSION pgdd;` would
go away.  In that case, we need to be aware of
the need to adjust for DDL changes made in `src/lib.rs` in version-to-version upgrade (e.g. ``sql/pgdd-0.3.1--0.4.0.sql``).

Those scenarios may need review depending on if
[pgrx #120](https://github.com/pgcentralfoundation/pgrx/issues/120)
is also resolved or not.

As it stands, `drop/create` is the upgrade path.

