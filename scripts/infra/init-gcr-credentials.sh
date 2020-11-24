#!/bin/bash
# Login to Google Cloud Registry using the Standalone Docker credential helper
# See https://cloud.google.com/container-registry/docs/advanced-authentication
#
# This script is intended to be use inside the brezel container or
# for a tpl-based project that contains the brezel as submodule.
# Login to GCP on the host is normally performed with the GCloud SDK.
#
# This script makes use of a service account created for accessing the
# project hosted on GCP from the brezel container. The service
# account key must be mounted in the container. Save the json file inside
# ${BREZEL_HOME}/secrets/ and pass `-secrets` to 'make run' in order to make
# the key available for the docker credential helper. The later will
# generate the short-lived token that provides access to the GCR.
# Variable GOOGLE_APPLICATION_CREDENTIALS (which contains the path to
# the json key and is used by the docker crendential helper) is defined
# in the environment by `dc-extends-secrets.yml`.

set -eu -o pipefail
_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
readonly ROOT_DIR=$(readlink -f "${_DIR}/../..")

# Get the credential helper.
# Inside the brezel container it should be `docker-crendential-gcr`,
# which has been installed in the image by the eponymous script.
# On the host it is usually `gcloud` from the Google SDK.
credential_helper () {
    if command -v docker-credential-gcr >/dev/null ; then
        echo 'docker-credential-gcr'
    elif command -v gcloud >/dev/null ; then
        echo 'gcloud'
    else
        return 1
    fi
}
credential_helper_args () {
    case "$1" in
        docker-credential-gcr)  echo 'configure-docker';;
        gcloud) echo 'auth' 'configure-docker';;
        *)  return 1
    esac
}

# Initialize Google Cloud Registry Credentials
init_gcr_crendentials () {
    local helper args
    helper=$(credential_helper) || {
        >&2 echo "Could not find credential helper for GCR on system. Please install it."
        return 0
    }
    args=$(credential_helper_args "${helper}")
    "$helper" ${args}
}

# Warn if GOOGLE_APPLICATION_CREDENTIALS is set but pointing to
# a non-existing or empty file
warn_credentials_file_invalid () {
    [[ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]] || return 0
    if [[ ! -s "${GOOGLE_APPLICATION_CREDENTIALS}" ]]; then
        echo 'WARNING|'
        echo 'WARNING| Variable GOOGLE_APPLICATION_CREDENTIALS'
        echo "WARNING| is set to '$GOOGLE_APPLICATION_CREDENTIALS'"
        echo 'WARNING| but the file does not exist or is empty.'
        echo 'WARNING|'
    fi
}

##
# main
##
main () {
    warn_credentials_file_invalid
    init_gcr_crendentials
}
main "${@}"
