#!/usr/bin/env bash
# This script installs gsutil
# https://cloud.google.com/storage/docs/gsutil_install

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    ca-certificates \
    curl

readonly URL="https://storage.googleapis.com/pub/gsutil.tar.gz"
mkdir -p /opt
curl -fsSL "${URL}" | tar xfz - -C /opt
