#!/usr/bin/env bash
# This script installs the Google Cloud SDK

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    ca-certificates \
    coreutils \
    curl

readonly VERSION="296.0.1"
readonly URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${VERSION}-linux-x86_64.tar.gz"
readonly HASH='27df575571eee39f337fc74384274a92dfc015b4da90dcbf9f79de0d5a9eb3e6'
readonly ARCHIVE='google-cloud-sdk.tar.gz'

curl -fsSL "${URL}" -o "${ARCHIVE}"
digest=$(sha256sum "${ARCHIVE}" | head -c 64)
[[ "${digest}" == "${HASH}" ]] || exit 1
mkdir -p /opt
tar xfz "${ARCHIVE}" -C /opt
rm -f "${ARCHIVE}"
