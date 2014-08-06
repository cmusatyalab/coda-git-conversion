# Convert Coda CVS repositories to Git

You need to have
[cvs-fast-export](http://www.catb.org/~esr/cvs-fast-export/) and
[reposurgeon](http://www.catb.org/esr/reposurgeon/) installed.

You will also need at least 3GB of free diskspace to hold the
intermediate files that are used during the rebuild. The final
repository packs down to about 11MB for the bare git repo and
21MB with the current sources checked out.

To initiate the conversion run:

```
make
```

This downloads the raw Coda CVS repositories (about 11MB) and extracts
them to a 'coda-mirror' subdirectory.  It will then fix up an unparsable
CVS tag. It also pulls down the development Coda git repositories and
cleans them up for further processing with reposurgeon.

Then the Makefile.coda/lwp/rpc2/rvm files are used to convert the
respective CVS and development repositories to canonical Git repos.

After this repositories will be in $project-git/ directories, then it is
time to start identifying missing author information, commits that
should be collapsed into one and merged branches that are still
disconnected from their merge point. Any fixups should be added to
$project.lift.

Finally we merge all histories together by combining the branches and
interleave commit histories and write the result to final-git.

