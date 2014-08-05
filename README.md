# Convert Coda CVS repositories to Git

You need to have
[cvs-fast-export](http://www.catb.org/~esr/cvs-fast-export/) and
[reposurgeon](http://www.catb.org/esr/reposurgeon/) installed.
Then run

```
make
```

This downloads the raw Coda CVS repositories (about 11MB) and extracts
them to a 'coda-mirror' subdirectory.  It will then fix up an unparsable
CVS tag. Then it pulls down the development Coda git repositories and
cleans them up for further processing with reposurgeon.

It then calls the Makefile.foo files which convert the respective CVS
repository mirrors to Git.

After this repositories will be in $project-git/ directories, then it is
time to start identifying missing author information, commits that
should be collapsed into one and and merged branches that are still
disconnected from their merge point. Any fixups should be added to
$project.lift.

We then merge all histories together by combining the branches and fix
up the commit ordering by importing and exporting from a git repository
named 'combined-git'. Finally we interleave commit histories and write
the result to final-git.

