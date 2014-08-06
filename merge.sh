#!/bin/sh

last_repo=
last_ts=0
n=1

(
  git --git-dir=lwp-git/.git log --first-parent --pretty="format:%ct lwp %H" master ; echo
  git --git-dir=rpc2-git/.git log --first-parent --pretty="format:%ct rpc2 %H" master ; echo
  git --git-dir=rvm-git/.git log --first-parent --pretty="format:%ct rvm %H" master ; echo
  git --git-dir=coda-git/.git log --first-parent --pretty="format:%ct coda %H" master ; echo
) | sort -n | while read curr_ts curr_repo commit
do
    if [ -n "$last_repo" -a "$curr_repo" != "$last_repo" ]
    then
        last_date=$(date --date="@$last_ts" --utc +"<%FT%TZ#$n>")
        curr_date=$(date --date="@$curr_ts" --utc +"<%FT%TZ#1>")

        # indices don't seem to work on the parent timestamp, so we have to manually
        # pick the right mark and fix up the lift file with sed after it is created.
        # adding the list here should help find the right mark.
        [ "$n" -ne "1" ] && echo "echo 1"
        [ "$n" -ne "1" ] && echo "$last_date,$curr_date list # $last_date"
        echo "$last_date,$curr_date reparent rebase # $last_repo>$curr_repo $commit"
        [ "$n" -ne "1" ] && echo "echo 0"
    fi
    [ "$curr_ts" -ne "$last_ts" ] && n=0
    last_repo=$curr_repo
    last_ts=$curr_ts
    n=$(expr $n + 1)
done

