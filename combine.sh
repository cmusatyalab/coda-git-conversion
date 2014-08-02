#!/bin/sh

reposurgeon "verbose 1" "prefer git" \
  "read lwp-git" "rename lwp" \
  "paths sub lib-src/lwp" \
  "branch master-lwp.cvs delete" \
  "read rpc2-git" "rename rpc2" \
  "paths sub lib-src/rpc2" \
  "branch master-rpc2.cvs delete" \
  "read rvm-git" "rename rvm" \
  "paths sub lib-src/rvm" \
  "branch master-rvm.cvs delete" \
  "read coda-git" "rename coda" \
  "branch master-coda.cvs delete" \
  "unite lwp rpc2 rvm coda" \
  "script combined.lift" \
  "fossils write >combined.fo" \
  "write >combined.fi"

rm -fr combined-git
reposurgeon "read <combined.fi" "prefer git" "rebuild combined-git"

