#!/usr/bin/env bash
# This script installs the Docker CLI (client)
# Group 'docker' is not created

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    ca-certificates \
    curl \
    gnupg2 \
    lsb-core \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update --quiet
apt-get install --quiet --assume-yes docker-ce-cli
