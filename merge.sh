#!/bin/sh

last_repo=
last_ts=0
n=1

( (
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
done ) | \
    sed 's/\(1999-12-28T19:51:23Z\)/\1!jaharkes@cs.cmu.edu/' | \
    sed 's/^<2006-05-26T18:30:11Z#2>/:22590/' | \
    sed 's/^<2006-07-26T18:42:41Z#5>/:22703/' | \
    sed 's/^<2006-07-26T18:52:26Z#3>/:22711/' | \
    sed 's/^<2006-11-02T19:41:08Z#10>/:23815/' | \
    sed 's/^<2007-06-26T18:19:58Z#2>/:24067/' | \
    sed 's/^<2007-08-01T18:30:51Z#6>/:24422/' | \
    sed 's/^<2007-12-10T18:31:51Z#6>/:24654/' | \
    sed 's/^<2008-08-08T15:35:46Z#3>/:25230/' | \
    sed 's/^<2012-02-10T14:58:12Z#5>/:25829/'
