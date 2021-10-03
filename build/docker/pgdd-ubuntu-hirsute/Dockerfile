FROM ubuntu:hirsute

LABEL maintainer="PgDD Project - https://github.com/rustprooflabs/pgdd"

ARG USER=docker
ARG UID=1000
ARG GID=1000
ARG PGXVERSION

RUN useradd -m ${USER} --uid=${UID}


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y make wget curl gnupg git
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ focal-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y \
        clang-12 llvm-12 clang libz-dev strace pkg-config \
        libxml2 libxml2-dev libreadline8 libreadline-dev \
        flex bison libbison-dev build-essential \
        zlib1g-dev libxslt-dev libssl-dev libxml2-utils xsltproc libgss-dev \
        libldap2-dev libkrb5-dev gettext tcl-tclreadline tcl-dev libperl-dev \
        libpython3-dev libprotobuf-c-dev libprotobuf-dev gcc \
        ruby ruby-dev rubygems \
        postgresql-server-dev-10 \
        postgresql-server-dev-11 \
        postgresql-server-dev-12 \
        postgresql-server-dev-13


RUN gem install --no-document fpm


USER ${UID}:${GID}
WORKDIR /home/${USER}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
ENV PATH="/home/${USER}/.cargo/bin:${PATH}"

#RUN /bin/bash rustup.sh -y \
#    && cargo install cargo-pgx --version ${PGXVERSION}
RUN /bin/bash rustup.sh -y \
    && cargo install --force --git "https://github.com/zombodb/pgx" \
        --branch "develop" \
        "cargo-pgx"


RUN mkdir -p /home/${USER}/.pgx/data-10 \
    && mkdir /home/${USER}/.pgx/data-11 \
    && mkdir /home/${USER}/.pgx/data-12 \
    && mkdir /home/${USER}/.pgx/data-13

RUN cargo pgx init \
    --pg10=/usr/lib/postgresql/10/bin/pg_config \
    --pg11=/usr/lib/postgresql/11/bin/pg_config \
    --pg12=/usr/lib/postgresql/12/bin/pg_config \
    --pg13=/usr/lib/postgresql/13/bin/pg_config
