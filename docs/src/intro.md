# What is PgDD?

The PostgreSQL Data Dictionary (`PgDD`) makes it easy to write simple SQL
queries to learn about your database.  PgDD is an in-database solution 
providing introspection via standard SQL query syntax. The goal is a
usable data dictionary directly available to all users of a PostgreSQL database.

This extension does not provide anything you cannot get directly from the
internal Postgres catalog tables (e.g. `pg_catalog.pg_class`).
PgDD makes it **easy** to get to standard, default information most analysts,
developers, and even DBAs need to access from time to time.


## Compatibility

PgDD has been tested to work for PostgreSQL 12 through 16.
This extension is built using the
[pgrx framework](https://github.com/pgcentralfoundation/pgrx).  Postgres
version support is expected to provide 5 years of support, but is ultimately
determined by what `pgrx` supports.

Installers are provided for a small number of Debian / Ubuntu systems using
the Docker build system documented under [create-installer.md](create-installer.md).

## Why not use `______`?

Why use PgDD when you could just use `psql`'s slash commands (e.g. `\d`)
or directly query the tables/views in `pg_catalog`?

If those tools provide what you need, great!  PgDD was created to provide
database insights without requiring a specific tool.  It also attempts
to be easy for end users that are **not DBAs**.


See the [Quick Start](quick-start.md) and the [Query](query.md)
guide for next steps.
