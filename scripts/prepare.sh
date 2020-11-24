#!/bin/bash
# This script is supposed to be invoked by `make prepare`
#
# The purpose of this script is to prepare the host system.

set -euo pipefail

# load common stuff
_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )

##
# main function
##

install_docker_compose () {
    local VERSION="1.26.0"
    local URL="https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m)"
    sudo curl -L "${URL}" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

install_nvidia_container_runtime () {
    [[ $(uname -s) == Linux* ]] || return 1
    sudo apt-get install nvidia-container-runtime
}

add_nvidia_runtime_to_docker_daemon () {
    sudo cat > /etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
    sudo systemctl reload docker
    sudo systemctl restart docker
}

main () {
    command -v docker-compose >/dev/null || install_docker_compose
    command -v nvidia-container-runtime >/dev/null || install_nvidia_container_runtime
    [[ -s /etc/docker/daemon.json ]] || add_nvidia_runtime_to_docker_daemon
}

main "${@:-}"
