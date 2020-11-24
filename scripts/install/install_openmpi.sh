#!/usr/bin/env bash
# This script installs OpenMpi

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    file

# Temporary folder
readonly TMP=$(mktemp -d)
trap 'rm -rf $TMP' EXIT
cd "${TMP}"

# Download
readonly VERSION="${1:-4.0.4}"
readonly NAME="openmpi-${VERSION}"
readonly ARCHIVE="${NAME}.tar.bz2"
readonly URL="https://download.open-mpi.org/release/open-mpi/v${VERSION%.*}/${ARCHIVE}"
curl -fsSLO "${URL}"

# Install
tar xjf "${ARCHIVE}"
cd "${NAME}"
./configure
make -j $(nproc)
make install
ldconfig
