#!/bin/sh
echo BUILD_DATE $(TZ=Etc/UTC date -Iseconds)
echo BUILD_SCM_HASH $(git rev-parse HEAD)
