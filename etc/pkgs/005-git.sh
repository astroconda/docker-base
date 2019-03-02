#!/bin/bash
set -xe

name=git
version=2.20.1
url=https://mirrors.edge.kernel.org/pub/software/scm/git/${name}-${version}.tar.xz

curl -LO ${url}
tar xf ${name}-${version}.tar.xz

pushd ${name}-${version}
    make configure
    ./configure --prefix=${TOOLCHAIN} \
        --with-curl \
        --with-openssl=${TOOLCHAIN}
    make -j${_maxjobs}
    make install-strip
popd
