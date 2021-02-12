#!/bin/bash
set -xe

# Disabled
exit 0

name=node
version=v10.15.0
srcdir=${name}-${version}
tarball=${srcdir}.tar.gz
url=https://nodejs.org/dist/${version}/${tarball}

curl -LO "${url}"
tar xf "${tarball}"
pushd "${srcdir}"
    export CFLAGS="${CFLAGS} -fPIC"
    ./configure --prefix=${TOOLCHAIN}
    make -j${_maxjobs}
    make install
popd
