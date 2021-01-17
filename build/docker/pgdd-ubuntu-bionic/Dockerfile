FROM ubuntu:bionic

LABEL maintainer="PgDD Project - https://github.com/rustprooflabs/pgdd"

ARG USER=docker
ARG UID=1000
ARG GID=1000
RUN useradd -m ${USER} --uid=${UID}


RUN apt-get update && apt-get install -y make wget curl gnupg
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
	&& wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y \
        postgresql-server-dev-10 \
        postgresql-server-dev-11 \
        postgresql-server-dev-12 \
        postgresql-server-dev-13 \
        libxml2 libxml2-dev libreadline7 libreadline-gplv2-dev flex bison libbison-dev build-essential zlib1g-dev libxslt-dev libssl-dev libxml2-utils xsltproc libgss-dev libldap2-dev libkrb5-dev gettext tcl-tclreadline tcl-dev libperl-dev libpython-dev libpython3-dev  libprotobuf-c-dev libprotobuf-dev gcc \
        ruby ruby-dev rubygems

RUN gem install --no-document fpm


USER ${UID}:${GID}
WORKDIR /home/${USER}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
ENV PATH="/home/${USER}/.cargo/bin:${PATH}"

RUN /bin/bash rustup.sh -y \
	&& cargo install cargo-pgx

RUN cargo pgx init \
	--pg10=/usr/lib/postgresql/10/bin/pg_config \
	--pg11=/usr/lib/postgresql/11/bin/pg_config \
	--pg12=/usr/lib/postgresql/12/bin/pg_config \
	--pg13=/usr/lib/postgresql/13/bin/pg_config 
