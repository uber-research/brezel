#!/usr/bin/env bash
# This script installs VirtualGL

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

# Make sure wget is installed
if ! command -v wget >/dev/null
then
    apt-get update --quiet
    apt-get install --quiet --assume-yes --no-install-recommends \
        ca-certificates gnupg2 wget
fi

readonly VERSION='2.6.3'
readonly URL="https://sourceforge.net/projects/virtualgl/files/${VERSION}/virtualgl_${VERSION}_amd64.deb/download"
wget "${URL}" -O "virtualgl_${VERSION}_amd64.deb"
dpkg -i "virtualgl_${VERSION}_amd64.deb" || true
apt-get install -f
