#!/bin/bash
set -xe

name=binutils
version=2.32
url=https://ftp.gnu.org/gnu/binutils/${name}-${version}.tar.gz

curl -LO ${url}
tar xf ${name}-${version}.tar.gz

mkdir -p binutils
pushd binutils
    ../${name}-${version}/configure \
        --prefix=${TOOLCHAIN} \
        --with-lib-path=${TOOLCHAIN_LIB}:/lib64:/usr/lib64:/usr/local/lib64 \
        --target=x86_64-pc-linux-gnu \
        --enable-shared \
        --enable-lto \
        --enable-gold \
        --enable-ld=default \
        --enable-plugins \
        --enable-threads \
        --enable-compressed-debug-sections=none \
        --disable-static \
        --disable-multilib \
        --with-sysroot=/ \
        --with-tune=generic
    make -j${_maxjobs}
    make install-strip
popd
