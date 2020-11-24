#!/bin/sh
# Adapted from https://github.com/bazelbuild/bazel/blob/3.7.0/scripts/docs/jekyll_build.sh.tpl
RUNFILES=$(cd ${JAVA_RUNFILES-$0.runfiles}/%{workspace_name} && pwd -P)
SOURCE_DIR="$RUNFILES/%{source_dir}"

serve() {
  TDIR=$(mktemp -d)
  RDIR=$(mktemp -d)
  trap "rm -fr $RDIR $TDIR" EXIT
  (cd $RDIR && \
    jekyll serve -s "$SOURCE_DIR" -d "$TDIR")
}

serve
