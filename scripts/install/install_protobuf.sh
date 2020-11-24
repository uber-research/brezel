#!/usr/bin/env bash
# This script installs Protobuf

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes \
    autoconf \
    automake \
    ca-certificates \
    curl \
    g++ \
    libtool \
    make \
    pkg-config \
    unzip

readonly VERSION='v3.10.0'
curl -sL "https://github.com/protocolbuffers/protobuf/archive/${VERSION}.tar.gz" | tar xz -C /tmp
cd "/tmp/protobuf-${VERSION/v}"
./autogen.sh
./configure CXXFLAGS="-std=c++14"
make -j$(nproc)
make install
ldconfig
