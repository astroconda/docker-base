#!/bin/bash
PROJECT=astroconda/base
VERSION="${1}"
if [[ -z ${VERSION} ]]; then
    echo "Project version required [e.g. 1.2.3]"
    exit 1
fi

docker build -t ${PROJECT}:latest -t ${PROJECT}:${VERSION} .
