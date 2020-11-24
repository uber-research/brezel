#!/usr/bin/env bash
# This script installs python by building it from source

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    build-essential \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    zlib1g-dev \
    wget

readonly VERSION="${1:-3.6.9}"
readonly INSTALL="${2:-install}"
readonly ARCHIVE="Python-${VERSION}.tgz"
readonly URL="https://www.python.org/ftp/python/${VERSION}/${ARCHIVE}"

readonly TMP=$(mktemp --directory)
trap 'rm -rf $TMP' EXIT
cd "${TMP}"

wget "${URL}"
tar xf "${ARCHIVE}"
cd "${ARCHIVE%.tgz}"
./configure --enable-optimizations
make "-j$(nproc)"
make ${INSTALL}
