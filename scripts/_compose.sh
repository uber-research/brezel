#!/bin/bash
# This script is supposed to be sourced by build.sh or run.sh
#
# The purpose of this script is to define utility functions that can be use to
# prepare a `docker-compose` command. For example it can set the variable
# `COMPOSE_FILE` used by the docker-compose CLI. This variable contains the list
# of all the yaml configuration files. By default, the list contains
# only the main docker-compose.yml file.
#
# For each argument -{ext} (starting with a dash) given to this script,
# the corresponding configuration file "${YML_DIR}/dc-extends-{ext}.yml"
# is added to the list. Unless declared, YML_DIR=docker.
#
set -euo pipefail

# Ensure we are not inside a docker container already
running_in_docker() {
    [[ -r /proc/self/cgroup ]] || return 1
    awk -F/ '$2 == "docker"' /proc/self/cgroup | read
}
if running_in_docker
then
    echo '[WARNING] Already inside container. Nothing to do.'
    exit 0
fi

# Location of docker-compose configs
YML_DIR="${YML_DIR:-docker}"
YML_OTHER_DIR="${ROOT:+${ROOT#$PWD/}/${YML_DIR}}"

# Compose CLI environment variables
export COMPOSE_PROJECT_NAME='brezel'
export COMPOSE_FILE="${YML_DIR}/docker-compose.yml"

##
# compose functions
#

list_extensions_in () {
    local SEARCH="$1"
    local ext
    while read f
    do
        ext="${f##*dc-extends}"
        echo -e "${ext%.yml} (${f})"
    done < <(find "${SEARCH}/" -maxdepth 1 -name "dc-extends-*.yml")
}

list_extensions () {
    list_extensions_in "${YML_DIR}"
    if [[ -d "${YML_OTHER_DIR}" ]]; then
        list_extensions_in "${YML_OTHER_DIR}"
    fi
}

print_extensions () {
    column -t -c 2 <(list_extensions)
}

# Push back an extended docker-compose file to environment variable COMPOSE_FILE
# Here the script is looking for a file with the following name format inside
# the docker directory: 'dc-extends-*.yml'
# The script aborts if the file cannot be found.
append_compose_file () {
    local extname="${1#-}"
    local extfile=$(extension_filename "${extname}")
    if [[ -f "${YML_DIR}/${extfile}" ]]; then
        COMPOSE_FILE="${COMPOSE_FILE}:${YML_DIR}/${extfile}"
    elif [[ -f "${YML_OTHER_DIR}/${extfile}" ]]; then
        COMPOSE_FILE="${COMPOSE_FILE}:${YML_OTHER_DIR}/${extfile}"
    else
        echo "Cannot find extension file '${extfile}'"
        echo "Available extensions are:"
        print_extensions
        exit 1
    fi
}

extension_filename () {
    echo "dc-extends-${1}.yml"
}
