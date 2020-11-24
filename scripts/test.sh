#!/bin/bash
# This script is supposed to be invoked by `make test`

# Run bazel tests of the repository
set -euo pipefail
make run-ci
