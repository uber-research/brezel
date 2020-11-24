#!/bin/sh
cat << @EOF
_status = '''
$(cat bazel-out/stable-status.txt bazel-out/volatile-status.txt)
'''
buildinfo = dict()
for l in _status.splitlines():
  ll = l.strip().split(None, 1)
  if len(ll) == 2:
    buildinfo[ll[0]] = ll[1]
