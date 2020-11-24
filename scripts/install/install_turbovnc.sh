#!/usr/bin/env bash
# This script installs TurboVNC

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

readonly VERSION='2.2.3'
readonly URL="https://sourceforge.net/projects/turbovnc/files/${VERSION}/turbovnc_${VERSION}_amd64.deb/download"
wget "${URL}" -O "turbovnc_${VERSION}_amd64.deb"
dpkg -i "turbovnc_${VERSION}_amd64.deb"
apt-get install xfce4 xfce4-goodies
echo /opt/TurboVNC/bin/vncserver
