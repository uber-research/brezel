#!/usr/bin/env bash
# This script installs OpenCV

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    libgtk2.0-dev \
    pkg-config \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    python3-dev \
    python3-numpy \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libdc1394-22-dev

# Temporary folder
readonly TMP=$(mktemp -d)
trap 'rm -rf $TMP' EXIT
cd "${TMP}"

# Download
readonly VERSION="${1:-4.4.0}"
readonly NAME="opencv-${VERSION}"
readonly ARCHIVE="${VERSION}.tar.gz"
readonly URL="https://github.com/opencv/opencv/archive/${ARCHIVE}"
curl -fsSLO "${URL}"

# Install
tar xzf "${ARCHIVE}"
cd "${NAME}"
mkdir build && cd build
cmake -D WITH_JASPER=ON -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local ..
make -j $(nproc)
make install
