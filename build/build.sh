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

PG_VER=$1

if [ -z ${PG_VER} ]; then
    echo 'usage:  ./build.sh <PG_VER>'
    echo ' e.g. ./build.sh pg13'
    exit 1
fi

echo $BASE
echo $VERSION
echo $LOGDIR
echo $ARTIFACTDIR


mkdir -p ${LOGDIR}
mkdir -p ${ARTIFACTDIR}

for image in `ls docker/` ; do
    OS_DIST=$(echo ${image}|cut -f2 -d-)
    OS_VER=$(echo ${image}|cut -f3 -d-)


    echo $OS_DIST
    echo $OS_VER
    echo "Pg Version: ${PG_VER}"

    cd ${BUILDDIR}

    cd docker/${image}
    echo ${image}
    echo "  Building Docker image"
    docker build -t ${image} . 2>&1 > ${LOGDIR}/${image}-build.log || exit 1


    echo "Build PgDD: ${image}-${PG_VER}"
    docker run \
        -e pgver=${PG_VER} \
        -e image=${image} \
        -w /build \
        -v ${BASE}:/build \
        --rm \
        ${image} \
        /bin/bash -c '/build/build/package.sh ${pgver} ${image}' \
            > ${LOGDIR}/${image}-${PG_VER}-package.sh.log 2>&1 || exit 1

    echo "${image}-${PG_VER}:  finished"

done


# Collect artifacts
cd $BASE

echo "Copying artifacts..."

for f in $(find target -name "*.deb") $(find target -name "*.rpm") $(find target -name "*.apk"); do
    echo "copy: ${f}"
    cp $f $ARTIFACTDIR/
done
