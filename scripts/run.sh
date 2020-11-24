#!/bin/bash
# This script is supposed to be invoked by `make run`
#
# The purpose of this script is to invoke `docker-compose run`, with
# a configuration prepared by _compose.sh.
#
# Example: at the top level, a user enters  `make run-x11-secrets-p80_8050-p50051`
#   which is translatted by the Makefile into command
#     ./scripts/run.sh -x11 -secrets -p80_8050 -p50051
#   so the variable COMPOSE_FILE will be set with the value
#     "docker/docker-compose.yml:docker/dc-extends-x11.yml:docker/dc-extends-secrets.yml"
#   The final command issued by this script is equivalent to
#     docker-compose -f docker/docker-compose.yml \
#         -f docker/dc-extends-x11.yml \
#         -f docker/dc-extends-secrets.yml \
#             run \
#             -p 8050:80 \
#             -p 50051:50051 \
#             brezel
#
# In the absence of port-forwarding option, service ports are honored (with --service-ports).
set -euo pipefail

# load common stuff
_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
source "${_DIR}/_compose.sh"

# Extra port-forwarding
DOCKER_PUBLISH_OPT="${DOCKER_PUBLISH_OPT:-}"

##
# run functions
#

run_brezel_container () {
    local user_opt="${DOCKER_USER+--user ${DOCKER_USER}}"
    local port_opt="${DOCKER_PUBLISH_OPT:---service-ports}"
    local service="${RUN_IMAGE:-brezel}"
    ${BREZEL_SUDO:-} docker-compose run ${user_opt} ${port_opt} "${service}"
}

print_run_extensions () {
    echo '-root'
    echo '-pXXXX'
    echo '-pXXXX_XXXX'
    print_extensions
}

##
# main function
##
process_arguments () {
    while (($# > 0)); do
        case "$1" in
            -list)  print_run_extensions; exit 0; ;;
            -root)  DOCKER_USER='root' ;;
            -p[0-9]*_[0-9]*)   DOCKER_PUBLISH_OPT="${DOCKER_PUBLISH_OPT} -p $(sed -E 's/-p([0-9]+)_([0-9]+)/\1:\2/' <<< "$1")" ;;
            -p[0-9]*)   DOCKER_PUBLISH_OPT="${DOCKER_PUBLISH_OPT} -p ${1#-p}:${1#-p}" ;;
            -*)   append_compose_file "$1" ;;
            '')   ;;
            *)  abort_unknown_option "$1" ;;
        esac
        shift
    done
}

process_default_arguments () {
    local args="${@:-}"
    if [[ -n "${args:-}" ]]; then
        local arr=(${args//:/ })
        process_arguments "${arr[@]}"
    fi
}

main () {
    process_default_arguments "${BREZEL_RUN_PREPEND_ARGS:-}"
    process_arguments "${@:-}"
    process_default_arguments "${BREZEL_RUN_APPEND_ARGS:-}"
    run_brezel_container
}

abort_unknown_option () {
    echo "Unknown option '$1'. Abort."
    exit 1
}

main "${@:-}"
