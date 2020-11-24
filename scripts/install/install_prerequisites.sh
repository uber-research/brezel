#!/usr/bin/env bash

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes \
    cmake \
    libspatialindex-dev \
    pkg-config \
    python3-dev \
    uuid-dev
