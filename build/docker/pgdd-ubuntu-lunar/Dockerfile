# Ubuntu Lunar is an intermediate release of Ubuntu, not an LTS version.
# Non-LTS veresion are minimally supported until the next LTS version is released.
FROM ubuntu:lunar

LABEL maintainer="PgDD Project - https://github.com/rustprooflabs/pgdd"

ARG USER=ubuntu
ARG UID=1000
ARG GID=1000
ARG PGRXVERSION

# Ubuntu Lunar (23.04) has the ubuntu user as ID 1000. Why now when not in jmmay?
#RUN useradd -m ${USER} --uid=${UID}


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y make wget curl gnupg git postgresql-common

RUN sh /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

RUN apt-get update && apt-get upgrade -y --fix-missing
RUN apt-get install -y --fix-missing \
        clang-14 llvm-14 clang libz-dev strace pkg-config \
        libxml2 libxml2-dev libreadline8 libreadline-dev \
        flex bison libbison-dev build-essential \
        zlib1g-dev libxslt-dev libssl-dev libxml2-utils xsltproc libgss-dev \
        libldap-dev libkrb5-dev gettext tcl-tclreadline tcl-dev libperl-dev \
        libpython3-dev libprotobuf-c-dev libprotobuf-dev gcc \
        ruby ruby-dev rubygems \
        postgresql-12 postgresql-server-dev-12 \
        postgresql-13 postgresql-server-dev-13 \
        postgresql-14 postgresql-server-dev-14 \
        postgresql-15 postgresql-server-dev-15 \
        postgresql-16 postgresql-server-dev-16 \
    && apt autoremove -y


RUN gem install --no-document fpm


USER ${UID}:${GID}
WORKDIR /home/${USER}

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
ENV PATH="/home/${USER}/.cargo/bin:${PATH}"

RUN /bin/bash rustup.sh -y \
    && cargo install --locked cargo-pgrx --version ${PGRXVERSION}
