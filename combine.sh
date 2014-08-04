#!/bin/sh

if [ ! -d combined-git ] ; then
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
      "unite coda lwp rpc2 rvm" \
      "branch master rename master-rpc2" \
      "branch master-coda rename master" \
      "fossils write >combined.fo" "write >combined.fi"

    rm -fr combined-git
    reposurgeon "read <combined.fi" "prefer git" "rebuild combined-git"
fi

git --git-dir=combined-git/.git fast-export --signed-tags=strip --date-order --all \
    > recombined.fi

reposurgeon "verbose 1" "prefer git" \
  "read <recombined.fi" \
  "script merge.lift" \
  "fossils write >final.fo" "write >final.fi"

rm -fr final-git
reposurgeon "read <final.fi" "prefer git" "rebuild final-git"
