# Borrowed heavily from https://github.com/zombodb/zombodb/blob/master/build/build.sh
#
# Copyright 2018-2020 RustProof Labs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
#! /bin/bash

BUILDDIR=`pwd`
BASE=$(dirname `pwd`)
VERSION=$(cat $BASE/pgdd.control | grep default_version | cut -f2 -d\')
LOGDIR=${BASE}/target/logs
ARTIFACTDIR=${BASE}/target/artifacts

echo $BASE
echo $VERSION
echo $LOGDIR
echo $ARTIFACTDIR


mkdir -p ${LOGDIR}
mkdir -p ${ARTIFACTDIR}

rm -rf ${ARTIFACTDIR}
for image in `ls docker/` ; do
    OS_DIST=$(echo ${image}|cut -f2 -d-)
    OS_VER=$(echo ${image}|cut -f3 -d-)
    PG_VER=$(echo ${image}|cut -f4 -d-)

    echo $OS_DIST
    echo $OS_VER
    echo $PG_VER

    cd ${BUILDDIR}

    cd docker/${image}
    echo ${image}
    echo "  Building Docker image"
    docker build -t ${image} . 2>&1 > ${LOGDIR}/${image}-build.log || exit 1

    BUILDDIR = "_build"
    echo "${image}-${PGVER}:  Copying PgDD code to $BUILDDIR"
   # rm -rf ${BUILDDIR} > /dev/null
    mkdir ${BUILDDIR}
    cp -Rp ../ ${BUILDDIR}



    echo "${image}-${PG_VER}:  Building PgDD"
    docker run \
        -e pgver=${PG_VER} \
        -e image=${image} \
        -w /build \
        -v ${BUILDDIR}:/build \
        --rm \
        ${image} \
        /bin/bash -c './package.sh $pgver ${image}' \
            > ${LOGDIR}/${image}-${PG_VER}-package.sh.log 2>&1 || exit_with_error "${image}-${PG_VER}:  build failed"

    echo "${image}-${PG_VER}:  finished"



    cd ${ARTIFACTDIR}/${image}
    echo ${image} | grep centos 2>&1 > /dev/null
    if [ "$?" == "0" ] ; then
        echo "  building rpm package"
        echo " ... Support coming soon!"
    else
        echo "  building deb package"
        docker run -e DESTDIR=/build/target/artifacts/${image} -w /build -v ${BASE}:/build ${image} cargo deb 2>&1 > ${LOGDIR}/${image}-compile.log || exit 1
    fi
done