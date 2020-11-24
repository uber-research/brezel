#!/usr/bin/env bash
# This script installs the Docker credential helper
# for interacting with the Goodle Cloud Registry.

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

readonly VERSION="2.0.0"
readonly URL="https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v${VERSION}/docker-credential-gcr_linux_amd64-${VERSION}.tar.gz"
curl -fsSL "${URL}" | tar xz --to-stdout ./docker-credential-gcr > /usr/bin/docker-credential-gcr
chmod +x /usr/bin/docker-credential-gcr
