# Convert Coda CVS repositories to Git

First things first, grab the CVS repository data,

```
/bin/sh bootstrap.sh
```

This downloads the raw Coda CVS repositories (about 11MB) and extracts them to
a 'coda-mirror' subdirectory.  It will then fix up an unparsable CVS tag.

The following Makefiles convert the respective CVS repository mirrors to Git
and depend on having [reposurgeon](http://www.catb.org/esr/reposurgeon/)
installed,

```
make -f Makefile.lwp
make -f Makefile.rpc2
make -f Makefile.rvm
make -f Makefile.coda
```

After this repositories will be in $project-git/ directories, then it is time
to start identifying missing author information, commits that should be
collapsed into one and and merged branches that are still disconnected from
their merge point.

