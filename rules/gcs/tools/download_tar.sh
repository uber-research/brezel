#!/usr/bin/env bash
set -eu -o pipefail

# relative path of the archive bazel expects us to create
readonly ARCHIVE="${1}"

# URI location of the folder on Google Cloud Storage
readonly URI="${2}"

# the gsutil binary provided by bazel for downloading the folder
readonly GSUTIL="${3}"

# the expected checksum of the downloaded archive (optional)
readonly CHECKSUM="${4:-}"

# use archive extension to find out which argument we give to tar
tar_arg () {
    case "${ARCHIVE}" in
        *.tar.gz)   echo "zcf";;
        *.tar.xz)   echo "Jcf";;
        *.tar)      echo "cf";;
        *)  return 1;;
    esac
}

# pass options to tar in order to make it portable
export GZIP='--no-name'
export LANG='en_US.UTF-8'
tar_opts () {
    echo "--mtime=2000-01-01 --sort=name"
}

# create a temporary directory for downloading the files
# remove it at end of script
readonly TMPDIR=$(mktemp --directory)
trap 'rm -rf "${TMPDIR}"' EXIT

# download the full folder
${GSUTIL} -m cp -r "$URI" "${TMPDIR}"

# package the downloaded folder in the archive
# strip the temporary folder
tar $(tar_arg) "${ARCHIVE}" $(tar_opts) -C "${TMPDIR}" .

# compute checksum and verify it
sha256=$(sha256sum "${ARCHIVE}" | head -c 64)
if [[ -z "${CHECKSUM:-}" ]]; then
    echo -e "\x1B[33mDEBUG:\x1B[0m Rule 'gcs_tar' indicated that a canonical reproducible form can be obtained by modifying arguments sha256 = \"${sha256}\""
elif [[ "${CHECKSUM}" != "${sha256}" ]]; then
    echo "Checksum verification failed (expected: ${CHECKSUM}, downloaded: ${sha256})"
    exit 1
fi
exit 0
