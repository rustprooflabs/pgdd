# What is PgDD?

The PostgreSQL Data Dictionary (`PgDD`) is an in-database solution to provide
introspection via standard SQL query syntax. This extension makes it easy to
provide a usable data dictionary to all users of a PostgreSQL database.

This extension does not provide anything you cannot get directly from the
internal Postgres catalog tables (e.g. `pg_catalog.pg_class`). The goal
of this extension is to make it **easy** to get the standard, default
information most analysts, developers, and even DBAs need to access
from time to time.


## Compatibility

PgDD has been tested to work for PostgreSQL 12 through 16.
This extension is built using the
[pgrx framework](https://github.com/pgcentralfoundation/pgrx).  Postgres
version support is expected to provide 5 years of support, but is ultimately
determined by what `pgrx` supports.

Installers are provided for a small number of Debian / Ubuntu systems using
the Docker build system documented under [create-installer.md](create-installer.md).

