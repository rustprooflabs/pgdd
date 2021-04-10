# PgDD Advanced installation

This page covers installing PgDD from source locally, and the Docker build
method based on [ZomboDB's build system](https://github.com/zombodb/zombodb)
used to create the binaries.


## Install `pgdd` from source


One way to install `pgdd` is to install from source by cloning this repository.

### Prereqs

Pgx and its dependencies are the main prereq for PgDD.
Install Prereqs and ensure PostgreSQL dev tools are installed.

> See the [Cargo PGX](https://github.com/zombodb/pgx/tree/master/cargo-pgx)
documentation for more information on using pgx.


```bash
sudo apt install postgresql-server-dev-all libreadline-dev zlib1g-dev curl
```

[Install Rust](https://www.rust-lang.org/tools/install) and Pgx.

```bash
curl https://sh.rustup.rs -sSf | sh -s -- -y
cargo install cargo-pgx
cargo install cargo-deb
```

Initialize pgx.  Need to run this after install AND occasionally to get updates to Postgres versions.

```bash
cargo pgx init
```


### Clone PgDD repo

```bash
mkdir ~/git
cd ~/git
git clone https://github.com/rustprooflabs/pgdd.git
cd ~/git/pgdd
```

### Test deployment

Specify version, `pg10` through `pg13` are currently supported. This command will
start a test instance of Postgres on port `28812`.  Using a different version changes the last two digits of the port!


```bash
cargo pgx run pg12
```

Example output.

```bash
    Stopping Postgres v12
building extension with features `pg12`
"cargo" "build" "--features" "pg12" "--no-default-features"
    Finished dev [unoptimized + debuginfo] target(s) in 0.07s

installing extension
     Copying control file to `/home/username/.pgx/12.3/pgx-install/share/postgresql/extension/pgdd.control`
     Copying shared library to `/home/username/.pgx/12.3/pgx-install/lib/postgresql/pgdd.so`
     Writing extension schema to `/home/username/.pgx/12.3/pgx-install/share/postgresql/extension/pgdd--0.3.sql`
    Finished installing pgdd
    Starting Postgres v12 on port 28812
    Re-using existing database pgdd
```

In the test instance of psql, create the extension in database.

```bash
CREATE EXTENSION pgdd;
```


## Build binary packages

Debian/Ubuntu Bionic binaries are available for 0.4.0
(first [pgx](https://github.com/zombodb/pgx) version)
and on.  More distributions will be made available in the future.


```bash
cd build/
time bash ./build.sh
```

Tagged versions will be attached to their [releases](https://github.com/rustprooflabs/pgdd/releases).

During development some versions may be copied to the `./standalone/` directory.

```bash
cp ./target/artifacts/* ./standalone/
```

