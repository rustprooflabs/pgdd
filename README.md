# PostgreSQL Data Dictionary (pgdd)

The PostgreSQL Data Dictionary (`PgDD`) is an in-database solution to provide
introspection via standard SQL query syntax. This extension makes it easy to
provide a usable data dictionary to all users of a PostgreSQL database.

See the [full project documentation](https://rustprooflabs.github.io/pgdd/)
for more information.







## PgDD UI

The [PgDD UI](https://github.com/rustprooflabs/pgdd-ui) project provides
a lightweight Flask interface to the the PgDD extension.

### Version checking

PgDD UI handles version checking with the Python `packaging` module so
PgDD versioning must conform to
[PEP 440](https://www.python.org/dev/peps/pep-0440/).


----

## Caveats

End user caveats:

* `pg_dump` ignores rows where `s_name = 'dd'`



