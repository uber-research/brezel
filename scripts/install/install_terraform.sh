#!/usr/bin/env bash
# This script installs the Terraform CLI (client)

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
    curl \
    unzip

readonly VERSION='0.13.5'
readonly URL="https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip"
readonly SHA256='f7b7a7b1bfbf5d78151cfe3d1d463140b5fd6a354e71a7de2b5644e652ca5147'
readonly ZIP='terraform.zip'

curl -fsSL "${URL}" -o "${ZIP}"
digest=$(sha256sum 'terraform.zip' | head -c 64)
if [[ "${digest}" != "${SHA256}" ]]; then
    echo "actual digest: $digest, expected: ${SHA256}"
    exit 1
fi
unzip "${ZIP}"
mkdir -p /usr/local/bin
mv -f terraform /usr/local/bin/
rm -f "${ZIP}"
