#!/usr/bin/env bash
# This script installs CMake
# https://cmake.org/download/

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    coreutils

# Download
readonly VERSION="${1:-3.10.2}"
readonly ARCHIVE="cmake-${VERSION}-Linux-x86_64.tar.gz"
readonly URL="https://github.com/Kitware/CMake/releases/download/v${VERSION}/${ARCHIVE}"
cd /tmp
curl -fsSLO "${URL}"

# Check
readonly SHA256="${2:-}"
if [[ -n "${SHA256}" ]]; then
    digest=$(sha256sum "${ARCHIVE}" | head -c 64)
    if [[ "${digest}" != "${SHA256}" ]]; then
        echo "actual digest: $digest, expected: ${SHA256}"
        exit 1
    fi
fi

# Install
tar zxf "${ARCHIVE}" --strip-components 1 -C /usr/local

# Cleanup
rm -f "/tmp/${ARCHIVE}"
