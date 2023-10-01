# PgDD Advanced installation

This page covers installing PgDD from source locally, and the Docker build
method based on [ZomboDB's build system](https://github.com/zombodb/zombodb)
used to create the binaries for multiple versions.


## Create Binary installer for your system

The following steps walk through creating a package on a typical
Ubuntu based system with Postgres 15.


### Prereqs

pgrx and its dependencies are the main prereq for PgDD.
Install Prereqs and ensure PostgreSQL dev tools are installed.

> See the [Cargo pgrx](https://github.com/tcdi/pgrx/tree/master/cargo-pgrx)
documentation for more information on using pgrx.


```bash
sudo apt install postgresql-server-dev-all libreadline-dev zlib1g-dev curl \
    libssl-dev llvm-dev libclang-dev clang \
    graphviz
```

[Install Rust](https://www.rust-lang.org/tools/install) and pgrx.

```bash
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
```

Install `cargo-pgrx` regularly (see dev steps below for non-standard install).


```bash
cargo install --locked cargo-pgrx
```


Install `cargo-deb` used for packaging binaries.

```bash
cargo install cargo-deb
```


Initialize pgrx.  Need to run this after install AND occasionally to get updates
to Postgres versions or glibc updates.  Not typically required to follow pgrx
developments.


```bash
cargo pgrx init
```



The `fpm` step requires the `fpm` Ruby gem.

```bash
sudo apt install ruby-rubygems
sudo gem i fpm
```

Of course, the PgDD project itself is required.

```bash
mkdir ~/git
cd ~/git
git clone https://github.com/rustprooflabs/pgdd.git
cd ~/git/pgdd
```

### Create package

> Timing note:  `cargo pgrx package` takes ~ 2 minutes on my main dev machine.


```bash
cargo pgrx package --pg-config /usr/lib/postgresql/15/bin/pg_config
cd target/release/pgdd-pg15/

find ./ -name "*.so" -exec strip {} \;
OUTFILE=pgdd.deb
rm ${OUTFILE} || true
fpm \
  -s dir \
  -t deb -n pgdd \
  -v 0.5.0 \
  --deb-no-default-config-files \
  -p ${OUTFILE} \
  -a amd64 \
  .

sudo dpkg -i --force-overwrite ./pgdd.deb
```



## Use Docker to build binary packages

Ubuntu 22.04 (Jammy) binaries are available for 0.5.1 for Postgres 12
through Postgres 16.


```bash
cd build/
time bash ./build.sh
```

Tagged versions will be attached to their [releases](https://github.com/rustprooflabs/pgdd/releases).

### Specific Postgres version and OS

The `./build.sh` is setup to loop through all supported Postgres versions and OSs.

The Postgres version behavior can be altered manually by commenting out the line
with all versions and uncommenting the line with a specific Postgres version:

```bash
PG_VERS=("pg12" "pg13" "pg14" "pg15" "pg16")
#PG_VERS=("pg16")
```

To limit to a single OS change this line:

```bash
for image in `ls docker/ ` ; do
```

To `grep <osname>` to limit.

```bash
for image in `ls docker/ | grep lunar ` ; do
```

## pgrx Generate graphviz

```bash
cargo pgrx schema -d pgdd.dot
dot -Goverlap=prism -Gspline=ortho -Tjpg pgdd.dot > pgdd.jpg
```

![pgrx dependencies for pgdd](pgdd.jpg)


## Non-standard dev

When working against pgrx installed from a non-tagged branch, install pgrx using:

```bash
cargo install --locked --force --git "https://github.com/tcdi/pgrx" \
    --branch "develop" \
    "cargo-pgrx"
```


The following command can be used to force pgrx to overwrite the configs it needs to
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
cargo pgrx schema -f
```


## Non-standard In Docker

If testing this extension against non-standard pgrx install, update the
Dockerfile to install from the specific branch.

Change

```bash
RUN /bin/bash rustup.sh -y \
    && cargo install --locked cargo-pgrx
```

To

```bash
RUN /bin/bash rustup.sh -y \
    && cargo install --locked --force --git "https://github.com/tcdi/pgrx" \
        --branch "develop" \
        "cargo-pgrx"
```

