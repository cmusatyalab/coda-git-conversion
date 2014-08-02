#!/bin/sh
set -e
REPO=coda-mirror-20140711.tar.gz
SHA1=5b70fc1f21c2f1f447d747437026abb2bb2f67d9

echo "Retrieving Coda CVS repository data"
test -e $REPO || wget http://coda.cs.cmu.edu/~jaharkes/$REPO

echo -n "Validating... "
echo "$SHA1 *$REPO" | sha1sum -c || exit 0

echo "Extracting repositories to 'coda-mirror/'"
tar -xzf $REPO

echo "Fixing up broken CVS tags"
find coda-mirror/coda/utils-src/mond -name \*,v \
    -exec sed -i 's/(SOSP15_CDROM)/_SOSP15-CDROM/' {} \;

echo "Cloning Coda development git repositories"
git clone git://coda.cs.cmu.edu/project/coda/dev/coda.git coda-dev
git clone git://coda.cs.cmu.edu/project/coda/dev/lwp.git lwp-dev
git clone git://coda.cs.cmu.edu/project/coda/dev/rpc2.git rpc2-dev
git clone git://coda.cs.cmu.edu/project/coda/dev/rvm.git rvm-dev

