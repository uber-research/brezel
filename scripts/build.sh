#!/bin/bash
# This script is supposed to be invoked by `make build`.
set -euo pipefail

# load common stuff
_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
source "${_DIR}/_compose.sh"

##
# build functions
##

get_docker_group_id () {
    # Always use GID=127 for docker on OSX (Darwin)
    # On Mac, the socket /run/docker.sock belongs to root:daemon
    # Group daemon (id 1) already exists on linux
    if [[ $(uname -s) == Darwin* ]]; then
        echo 127
    else
        getent group docker | cut -d: -f3
    fi
}

build_brezel_image () {
    local did=$(get_docker_group_id)
    local image="${BUILD_IMAGE:-brezel}"
    local extra="${BUILD_EXTRA_OPTS:-}"
    export CONTEXT_ROOT=${ROOT+$ROOT}
    ${BREZEL_SUDO:-} docker-compose build ${extra} base
    ${BREZEL_SUDO:-} docker-compose build ${extra} --build-arg DOCKER_GID="${did}" "${image}"
}

print_build_extensions () {
    print_extensions | grep -E '^-(cuda)'
}

##
# main function
##

process_arguments () {
    while (($# > 0)); do
        case "$1" in
            -list)  print_build_extensions; exit 0; ;;
            -nocache)
                export BUILD_EXTRA_OPTS="${BUILD_EXTRA_OPTS:-} --no-cache"
                ;;
            -*)   append_compose_file "$1" ;;
            '')   ;;
            *)  abort_unknown_option "$1" ;;
        esac
        shift
    done
}

main () {
    process_arguments "${@:-}"
    build_brezel_image
}

abort_unknown_option () {
    echo "Unknown option '$1'. Abort."
    exit 1
}

main "${@:-}"
