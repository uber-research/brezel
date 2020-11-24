#!/usr/bin/env bash
# This script installs bazel

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
    gnupg2

readonly JDK='jdk1.8'
readonly VERSION="${1:-}"
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable ${JDK}" >> /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
apt-get update --quiet
apt-get install --quiet --assume-yes bazel${VERSION:+=$VERSION}
