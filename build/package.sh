# Borrowed heavily from https://github.com/zombodb/zombodb/blob/master/build/package.sh
#
# Copyright 2020 RustProof Labs
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

PG_VER=$1
IMAGE=$2

if [ "x${PG_VER}" == "x" ] || [ "x${IMAGE}" == "x" ] ; then
	echo 'usage:  ./package.sh <PG_VER> <image>'
	exit 1
fi

PKG_FORMAT=deb

set -x

OSNAME=$(echo ${IMAGE} | cut -f3-4 -d-)
VERSION=$(cat pgdd.control | grep default_version | cut -f2 -d\')


echo "PgDD Building for:  ${OSNAME}-${VERSION}"

PG_CONFIG_DIR=$(dirname $(grep ${PG_VER} ~/.pgx/config.toml | cut -f2 -d= | cut -f2 -d\"))
export PATH=${PG_CONFIG_DIR}:${PATH}

echo "   Packaging pgx"
cargo pgx package || exit $?



#
# cd into the package directory
#
BUILDDIR=`pwd`
cd target/release/pgdd-${PG_VER} || exit $?

# strip the binaries to make them smaller
find ./ -name "*.so" -exec strip {} \;

#
# then use 'fpm' to build a .deb
#
OUTNAME=pgdd_${OSNAME}_${PG_VER}-${VERSION}_amd64
if [ "${PKG_FORMAT}" == "deb" ]; then

	fpm \
		-s dir \
		-t deb \
		-n pgdd-${PG_VER} \
		-v ${VERSION} \
		--deb-no-default-config-files \
		-p ${OUTNAME}.deb \
		-a amd64 \
		. || exit 1

else
	echo Unrecognized value for PKG_FORMAT:  ${PKG_FORMAT}
	exit 1
fi

echo "Packing complete: ${OUTNAME}.deb"
