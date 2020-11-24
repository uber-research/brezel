#!/usr/bin/env bash
# This script installs orca and node.js

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

echo $'#!/bin/bash\nxvfb-run -a /usr/lib/node_modules/orca/bin/orca.js "$@"' > /usr/bin/orca.sh
curl -sL https://deb.nodesource.com/setup_12.x | bash
apt-get install  --quiet --assume-yes --no-install-recommends \
    nodejs \
    xvfb libgtkextra-dev libgconf2-dev libnss3 libasound2 libxtst-dev libxss1 libx11-xcb1
npm install -g electron@1.8.4 orca --unsafe-perm=true
chmod +x /usr/bin/orca.sh && ln -sf /usr/bin/orca.sh /usr/bin/orca