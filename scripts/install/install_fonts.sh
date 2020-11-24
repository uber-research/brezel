#!/usr/bin/env bash
# This script installs additional fonts

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    fonts-powerline \
    unzip \
    wget

# Install the patched version of package 'fonts-hack-ttf'
readonly TMP=$(mktemp -d)
trap 'rm -rf $TMP' EXIT
cd "$TMP"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip
mkdir -p /usr/share/fonts/truetype/hack
unzip -o Hack.zip -d /usr/share/fonts/truetype/hack
