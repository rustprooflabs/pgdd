FROM postgres:12

ENV PG_MAJOR 12

LABEL maintainer="PgDD Project - https://github.com/rustprooflabs/pgdd"

RUN apt-get update \
    && apt-cache showpkg postgresql-$PG_MAJOR \
    && apt-get install -y --no-install-recommends \
        make \
        postgresql-server-dev-$PG_MAJOR \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/pgdd
COPY *.sql ./
COPY pgdd.control ./
COPY Makefile ./

RUN make install

