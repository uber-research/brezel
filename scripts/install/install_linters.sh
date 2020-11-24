#!/usr/bin/env bash
# This script installs linters for the following languages:
# - bash (shellcheck)
# - python (pylint, autopep8)

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    pylint3 \
    python-autopep8 \
    shellcheck
