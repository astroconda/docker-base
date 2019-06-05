#!/bin/bash
set -xe

name=sqlite
version=autoconf-3280000
year=2019
url=https://sqlite.org/${year}/${name}-${version}.tar.gz

curl -LO ${url}
tar xf ${name}-${version}.tar.gz

pushd ${name}-${version}
    make configure
    ./configure --prefix=${TOOLCHAIN} \
        --disable-static \
        --enable-readline
    make -j${_maxjobs}
    make install
popd
