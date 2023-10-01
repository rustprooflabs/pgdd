# PgDD Docker Build System


This page covers two methods that can be used to build binary installers
for PgDD.
The two methods that can be used to build binaries are the Docker build system
and manually installing `pgrx` on the target OS and architecture.
Installers are specific to three (3) details:

* CPU Architecture
* Operating System version
* Postgres version


The Docker build method uses OS specific `Dockerfile` to provide one binary
installer for each supported Postgres version.  This is the best approach
when the appropriate `Dockerfile` already exists.


## Use Docker to build binary packages

The Docker build method was originally based on
[ZomboDB's build system](https://github.com/zombodb/zombodb) and has
evolved with this project since then.

To generate the full suite of binaries change into the `./build` directory
and run `build.sh`.  This currently creates 15 total binary installers for
3 different OSs (Postgres 12 - 16).

```bash
cd build/
time bash ./build.sh
```

Individual installers can be found under `./target/artifacts`.  A package of
all installers is saved to `./build/pgdd-binaries.tar.gz`.

> Tagged versions of PgDD include LTS OS binaries with their [release notes](https://github.com/rustprooflabs/pgdd/releases).


### Customize Docker Build system

The Docker build system can be adjusted locally to build a binary for
a specific Postgres version and/or specific OS.

The `./build/build.sh` script has the logic to be adjusted to control this.
The Postgres versions can be  altered manually by commenting out the line
with all versions and uncommenting the line with a specific Postgres version.
The two lines in the script are shown below.

```bash
PG_VERS=("pg12" "pg13" "pg14" "pg15" "pg16")
#PG_VERS=("pg16")
```


To only build for Postgres on a single OS, add a `grep <osname` command to the
loop logic.  The original file that runs for all OSs with Dockerfiles looks like
the following line.

```bash
for image in `ls docker/ ` ; do
```

To build for only `lunar` (Ubuntu 23.04) add ` | grep lunar ` as shown in the
following example.

```bash
for image in `ls docker/ | grep lunar ` ; do
```


## Create Binary Installer w/out Docker

The following steps walk through creating a package on a typical
Ubuntu based system with Postgres 15.  These manual instructions can be used
when you do not want to use the Docker based build system under `./build/`.


### Prerequisites

The main perquisites for PgDD are `pgrx` and its dependencies.
Install prereqs and ensure PostgreSQL dev tools are installed.

> See the [cargo pgrx](https://github.com/pgcentralfoundation/pgrx/tree/master/cargo-pgrx)
documentation for more information on using `pgrx`.


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


Initialize `pgrx`.  Need to run this after install AND occasionally to get updates
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

