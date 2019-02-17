#!/bin/bash
set -x

sudo yum install -y cmake glibc-static || exit 1
git clone https://github.com/krallin/tini.git
export CFLAGS="${CFLAGS} -DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"

pushd tini
    git checkout v0.18.0
    mkdir -p build
    pushd build
        cmake ..
        make
        install -m755 tini ${TOOLCHAIN_BIN}
    popd
popd

rm -rf tini
