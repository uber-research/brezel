#!/bin/bash
# This script can be used to run multiple commands on container start.
# Example usage in docker-compose.yml:
#     entrypoint: /entrypoint.sh
#     command:
#       - command1 arg11 arg12
#       - command2
# After processing all the commands (with `eval`), bash is started.
# If you need to run a different shell instead, start the last command
# with `exec`.
_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
PATH="$_DIR:$PATH"

while (($# > 0)); do
    eval $1
    shift
done

exec bash
