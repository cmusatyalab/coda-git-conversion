#!/bin/sh

reposurgeon "verbose 1" "prefer git" "script combined.lift" \
  "fossils write >combined.fo" "write >combined.fi"

rm -fr combined-git
reposurgeon "read <combined.fi" "prefer git" "rebuild combined-git"

