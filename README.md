# PostgreSQL Data Dictionary (pgdd)

> FIXME:  Link to new:  create-installer.html


----


## Non-LTS OS Support

Interim Ubuntu OS versions, such as 23.04, may have minimal support
through the inclusion of a `Dockerfile` under
[`./build/docker/`](https://github.com/rustprooflabs/pgdd/tree/main/build/docker).
The intent with these is to prepare for potential changes in the upcoming LTS
version, e.g. 24.04.

Binaries will not be provided for these interim OS's.  To get the binary for
one of these releases follow the instructions in the
[Advanced Installation](./ADVANCED-INSTALL.md) section, under
[the Docker section](ADVANCED-INSTALL.md#use-docker-to-build-binary-packages).






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



