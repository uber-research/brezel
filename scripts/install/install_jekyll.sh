#!/usr/bin/env bash
# This script installs Ruby and Jekyll

set -eu -o pipefail

# Require root
if [ "$EUID" -ne 0 ]; then
    echo 'Please run as root'
    exit 1
fi

# Installing debian deps
apt-get update --quiet
apt-get install --quiet --assume-yes --no-install-recommends \
    build-essential \
    curl \
    python3-dev \
    python3-pygments \
    ruby ruby-dev \
    liblzma-dev \
    unzip zlib1g-dev \

# Temporary directory
readonly TMP=$(mktemp -d)
trap 'rm -rf $TMP' EXIT
cd "${TMP}"

# Ruby deps
cat > ${TMP}/Gemfile <<- EOM
gem 'jekyll', '~> 3.8.6'
gem 'jekyll-paginate', '~> 1.0'
gem 'pygments.rb', '~> 0.6.0'
gem 'redcarpet', '~> 3.2', '>= 3.2.3'
gem 'jekyll-toc', '~> 0.13.1'
gem 'jekyll-sitemap', '~> 1.4.0'
gem 'just-the-docs', '~> 0.3.3'
EOM

gem install -g --no-rdoc --no-ri
