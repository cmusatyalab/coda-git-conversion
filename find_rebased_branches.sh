#!/bin/sh

last_commit=
last_ts=9999999999

(
  git --git-dir=final-git/.git log --first-parent --pretty="format:%at %H" master ; echo
) | while read curr_ts curr_commit
do
    if [ "$last_ts" -lt "$curr_ts" ]
    then
        last_date=$(date --date="@$last_ts" --utc +"<%FT%TZ>")
        curr_date=$(date --date="@$curr_ts" --utc +"<%FT%TZ>")

        echo "rebased branch at $last_date $last_commit"
        echo "                  $curr_date $curr_commit"
    fi
    last_commit=$curr_commit
    last_ts=$curr_ts
done
