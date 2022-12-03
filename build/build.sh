# Borrowed heavily from https://github.com/zombodb/zombodb/blob/master/build/build.sh
#
# Copyright 2018-2021 RustProof Labs
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
#!/bin/bash

BUILDDIR=`pwd`
BASE=$(dirname `pwd`)
VERSION=$(cat $BASE/pgdd.control | grep default_version | cut -f2 -d\')
LOGDIR=${BASE}/target/logs
ARTIFACTDIR=${BASE}/target/artifacts
PGXVERSION=0.6.0

PG_VERS=("pg11" "pg12" "pg13" "pg14" "pg15")
#PG_VERS=("pg15")

echo $BASE
echo $VERSION
echo $LOGDIR
echo $ARTIFACTDIR
echo "PGX Version: ${PGXVERSION}"

mkdir -p ${LOGDIR}
mkdir -p ${ARTIFACTDIR}

# Skipping focal for now, fails.
for image in `ls docker/ | grep jammy ` ; do

    OS_DIST=$(echo ${image}|cut -f2 -d-)
    OS_VER=$(echo ${image}|cut -f3 -d-)

    echo $OS_DIST
    echo $OS_VER
    echo "Pg Version: ${PG_VER}"

    cd ${BUILDDIR}

    cd docker/${image}
    echo "  Building Docker image: ${image}"
    docker build -t ${image} --build-arg PGXVERSION=${PGXVERSION}  . 2>&1 > ${LOGDIR}/${image}-build.log || exit 1

    for PG_VER in ${PG_VERS[@]} ; do

        echo "Build PgDD: ${image}-${PG_VER}"
        docker run \
            -e pgver=${PG_VER} \
            -e image=${image} \
            -v ${BASE}:/build \
            --rm \
            ${image} \
            /bin/bash -c '/build/build/package.sh ${pgver} ${image}' \
                > ${LOGDIR}/${image}-${PG_VER}-package.sh.log 2>&1 || echo 'Building this version might have encountered error.'

        echo "${image}-${PG_VER}:  finished"
    done


    echo "Copying artifacts for ${OS_DIST} ${OS_VER}"
    cd $BASE

    for f in $(find target -name "*.deb") $(find target -name "*.rpm") $(find target -name "*.apk"); do
        echo "copy: ${f}"
        cp $f $ARTIFACTDIR/
    done
done

tar -zcvf $BUILDDIR/pgdd-binaries.tar.gz -C $ARTIFACTDIR .

