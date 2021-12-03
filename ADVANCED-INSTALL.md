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
sudo apt install postgresql-server-dev-all libreadline-dev zlib1g-dev curl \
    libssl-dev llvm-dev libclang-dev clang \
    graphviz
```

[Install Rust](https://www.rust-lang.org/tools/install) and Pgx.

```bash
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
```

Install `cargo-pgx` regularly (see dev steps below for non-standard install).


```bash
cargo install cargo-pgx
```


Install `cargo-deb` used for packaging binaries.

```bash
cargo install cargo-deb
```


Initialize pgx.  Need to run this after install AND occasionally to get updates
to Postgres versions or glibc updates.  Not typically required to follow pgx
developments.


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
start a test instance of Postgres on port `28812`.  Using a different version
changes the last two digits of the port!


```bash
cargo pgx run pg13
```

Example output.

```bash
    Stopping Postgres v13
building extension with features `pg13`
"cargo" "build" "--features" "pg13" "--no-default-features"
    Finished dev [unoptimized + debuginfo] target(s) in 0.05s

installing extension
     Copying control file to `/home/username/.pgx/13.4/pgx-install/share/postgresql/extension/pgdd.control`
     Copying shared library to `/home/username/.pgx/13.4/pgx-install/lib/postgresql/pgdd.so`
    Building SQL generator with features `pg13`
"cargo" "build" "--bin" "sql-generator" "--features" "pg13" "--no-default-features"
    Finished dev [unoptimized + debuginfo] target(s) in 0.05s
 Discovering SQL entities
  Discovered 9 SQL entities: 0 schemas (0 unique), 6 functions, 0 types, 0 enums, 3 sqls, 0 ords, 0 hashes
running SQL generator with features `pg13`
"cargo" "run" "--bin" "sql-generator" "--features" "pg13" "--no-default-features" "--" "--sql" "/home/username/.pgx/13.4/pgx-install/share/postgresql/extension/pgdd--0.4.0-dev.sql"
    Finished dev [unoptimized + debuginfo] target(s) in 0.06s
     Running `target/debug/sql-generator --sql /home/username/.pgx/13.4/pgx-install/share/postgresql/extension/pgdd--0.4.0-dev.sql`
     Copying extension schema file to `/home/username/.pgx/13.4/pgx-install/share/postgresql/extension/pgdd--0.3.1--0.4.0-dev.sql`
     Copying extension schema file to `/home/username/.pgx/13.4/pgx-install/share/postgresql/extension/pgdd--0.3--0.3.1.sql`
    Finished installing pgdd
    Starting Postgres v13 on port 28813
    Re-using existing database pgdd
```

In the test instance of psql, create the extension in database.

```bash
CREATE EXTENSION pgdd;
```


## Build binary packages

Debian/Ubuntu Bionic binaries are available for 0.4.0
(first [pgx](https://github.com/zombodb/pgx) version)
and later.  More distributions will likely have binaries available in the future.


```bash
cd build/
time bash ./build.sh
```

Tagged versions will be attached to their [releases](https://github.com/rustprooflabs/pgdd/releases).

During development some versions may be copied to the `./standalone/` directory.

```bash
cp ./target/artifacts/* ./standalone/
```

## Pgx Generate graphviz

```bash
cargo pgx schema -d
dot -Goverlap=prism -Gspline=ortho -Tjpg extension.dot > extension.jpg
```

![pgx dependencies for pgdd v0.4.0](pgdd--0.4.0.jpg)


## Non-standard dev

When working against Pgx installed from a non-tagged branch, install pgx using:

```bash
cargo install --force --git "https://github.com/zombodb/pgx" \
    --branch "develop" \
    "cargo-pgx"
```

Or a beta branch

```bash
cargo install --force cargo-pgx --version 0.2.0-beta.4
```

Changes to `Cargo.toml` required in `[lib]` and `[dependencies]` sections.


```toml
[lib]
# rlib added to build against repo instead of crate (I think)
crate-type = ["cdylib", "rlib"]
#crate-type = ["cdylib"]
```


```toml
[dependencies]

pgx = { git = "https://github.com/zombodb/pgx", branch = "oh-no-type-resolution" }
pgx-macros = { git = "https://github.com/zombodb/pgx", branch = "develop" }
#pgx = "0.1.21"
#pgx-macros = "0.1.21"

# Won't be needed in final version (hopefully!)
pgx-utils = { git = "https://github.com/zombodb/pgx", branch = "develop" }

[dev-dependencies]
pgx-tests = { git = "https://github.com/zombodb/pgx", branch = "develop" }
#pgx-tests = "0.1.21"
```



The following command can be used to force pgx to overwrite the configs it needs to
for various dev related changes.

Clean things out.

```bash
cargo clean
```

If you're doing the above, you probably should remove the `Cargo.lock`
file while you're at it.  The more cautious may want to move it aside for a backup.

```bash
rm Cargo.lock
```

Force build the schema.


```bash
cargo pgx schema -f
```


## Non-standard In Docker

If testing this extension against non-standard pgx install, update the
Dockerfile to install from the specific branch.

Change

```bash
RUN /bin/bash rustup.sh -y \
    && cargo install cargo-pgx
```

To

```bash
RUN /bin/bash rustup.sh -y \
    && cargo install --force --git "https://github.com/zombodb/pgx" \
        --branch "develop" \
        "cargo-pgx"
```

