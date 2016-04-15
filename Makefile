
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
	( cd coda-dev ; git filter-branch --index-filter 'git rm --cached --ignore-unmatch .gitmodules lib-src/lwp lib-src/rpc2 lib-src/rvm' --tag-name-filter 'cat' --prune-empty -- --all )
	rm -r coda-dev/.git/refs/original

#
# Rebuild standalone git repositories with reposurgeon
#
%.cvs: coda-mirror
	$(MAKE) -f Makefile.$* local-clobber $@
	touch $@

%-git: %.cvs %-dev %.lift %.grafts
	$(RM) $*.fi
	$(RM) -r $@
	$(MAKE) -f Makefile.$* $@
	cp $*.grafts $*-git/.git/info/grafts
	# cannot safely delete branches with reposurgeon so we do it with git
	-git --git-dir=$*-git/.git branch -d master-$*.cvs

lwp-git: lwp-dev
rpc2-git: rpc2-dev
rvm-git: rvm-dev

combined-git: ${DSTREPOS} combined.lift
	$(RM) -r combined-git
	reposurgeon "verbose 1" "prefer git" "script combined.lift" \
		    "fossils write >combined.fo" "write >combined.fi"
	reposurgeon "read <combined.fi" "prefer git" "rebuild combined-git"

merge.lift: ${DSTREPOS} merge.sh
	sh merge.sh > merge.lift

recombined.fi: combined-git merge.lift
	$(RM) -r recombined-git
	git --git-dir=combined-git/.git fast-export --signed-tags=strip \
	    --date-order --all > dateordered.fi
	reposurgeon "verbose 1" "prefer git" \
		    "read <dateordered.fi" "script merge.lift" \
		    "fossils write >recombined.fo" "write >recombined.fi"
	#reposurgeon "read <recombined.fi" "prefer git" "rebuild recombined-git"

final-git: recombined.fi final.lift
	$(RM) -r final-git
	reposurgeon "verbose 1" "prefer git" \
		    "read <recombined.fi" "script final.lift" \
		    "fossils write >final.fo" "write >final.fi"
	reposurgeon "read <final.fi" "prefer git" "rebuild final-git"
	# cannot safely delete merged branches with reposurgeon so we do it with git
	git --git-dir=final-git/.git branch -d master-lwp
	git --git-dir=final-git/.git branch -d master-rpc2
	git --git-dir=final-git/.git branch -d master-rvm
	git --git-dir=final-git/.git repack -AdF --window=1250 --depth=250

#
# Clean up
#
distclean: clean
	$(RM) -r ${SRCREPOS}
	$(RM) coda-dev.submodules

clean:
	$(RM) -r ${DSTREPOS} combined-git final-git
	$(RM) *.fi *.fo
	rmdir *~

