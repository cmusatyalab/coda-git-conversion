
CVSREPOS=coda-mirror-20140711.tar.gz
CVSREPOSHA1=5b70fc1f21c2f1f447d747437026abb2bb2f67d9

SRCREPOS=coda-mirror coda-dev lwp-dev rpc2-dev rvm-dev
DSTREPOS=coda-git lwp-git rpc2-git rvm-git

all: ${DSTREPOS} final-git

#
# Retrieve and extract CVS/git development repositories
#
coda-mirror:
	test -e ${CVSREPOS} || wget http://coda.cs.cmu.edu/~jaharkes/${CVSREPOS}
	echo "${CVSREPOSHA1} *${CVSREPOS}" | sha1sum -c
	tar -xzf ${CVSREPOS}
	# Fix up broken CVS tags
	find coda-mirror/coda/utils-src/mond -name \*,v -exec sed -i 's/(SOSP15_CDROM)/_SOSP15-CDROM/' {} \;

%-dev:
	git clone git://coda.cs.cmu.edu/project/coda/dev/$*.git $@

coda-dev:
	git clone git://coda.cs.cmu.edu/project/coda/dev/coda.git coda-dev
	# Remove submodule links they are broken after the rewrite anyway.
	( cd coda-dev ; git log -p -- lib-src/lwp lib-src/rpc2 lib-src/rvm > coda-dev.submodules )
	( cd coda-dev ; git filter-branch --index-filter 'git rm --cached --ignore-unmatch .gitmodules lib-src/lwp lib-src/rpc2 lib-src/rvm' --tag-name-filter 'cat' -- --all )
	rm -r coda-dev/.git/refs/original

#
# Rebuild standalone git repositories with reposurgeon
#
%.cvs: coda-mirror
	$(MAKE) -f Makefile.$* local-clobber $@
	touch $@

%.fi: %.cvs %-dev %.lift
	$(MAKE) -f Makefile.$* $@

combined.fi: ${DSTREPOS} combined.lift
	reposurgeon "verbose 1" "prefer git" "script combined.lift" \
		    "fossils write >combined.fo" "write >combined.fi"

recombined.fi: combined-git
	git --git-dir=$</.git fast-export --signed-tags=strip \
	    --date-order --all > $@

final.fi: recombined.fi merge.lift
	reposurgeon "verbose 1" "prefer git" \
		    "read <recombined.fi" "script merge.lift" \
		    "fossils write >combined.fo" "write >combined.fi"

%-git: %.fi
	$(RM) -rf $@
	reposurgeon "read <$<" "prefer git" "rebuild $@"

#
# Clean up
#
distclean: clean
	$(RM) -rf ${SRCREPOS}
	$(RM) coda-dev.submodules

clean:
	$(RM) -rf ${DSTREPOS} combined-git final-git
	$(RM) *.fi *.fo
	rmdir *~

