#!/usr/bin/env bash
# This script installs the Kubernetes CLI (kubectl)

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    lsb-core \
    software-properties-common

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update --quiet
apt-get install --quiet --assume-yes kubectl

# Install krew (kubectl plugin manager)
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
cd /tmp
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}"
tar zxvf krew.tar.gz
KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64"
"$KREW" install --manifest=krew.yaml --archive=krew.tar.gz
"$KREW" update

# Install kubectx and kubens
cd /tmp
VERSION='v0.9.1'
BASE_URL="https://github.com/ahmetb/kubectx/releases/download/${VERSION}"
curl -fsSLO "${BASE_URL}/kube{ctx,ns}_${VERSION}_linux_x86_64.tar.gz"
tar zxf "kubectx_${VERSION}_linux_x86_64.tar.gz" -C /usr/local/bin
tar zxf "kubens_${VERSION}_linux_x86_64.tar.gz" -C /usr/local/bin

# Cleanup
rm -f /tmp/krew*
rm -f /tmp/kube*
