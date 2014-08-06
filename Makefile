
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

%-git: %.cvs %-dev %.lift
	$(RM) $*.fi
	$(RM) -r $@
	$(MAKE) -f Makefile.$* $@

lwp-git: lwp-dev
rpc2-git: rpc2-dev
rvm-git: rvm-dev

combined-git: ${DSTREPOS} combined.lift
	$(RM) -r combined-git
	reposurgeon "verbose 1" "prefer git" "script combined.lift" \
		    "fossils write >combined.fo" "write >combined.fi"
	reposurgeon "read <combined.fi" "prefer git" "rebuild combined-git"

recombined.fi: combined-git
	git --git-dir=combined-git/.git fast-export --signed-tags=strip \
	    --date-order --all > recombined.fi

merge.lift: ${DSTREPOS} merge.sh Makefile
	sh merge.sh > merge.lift
	sed -i 's/\(1999-12-28T19:51:23Z\)/\1!jaharkes@cs.cmu.edu/' merge.lift
	#sed -i 's/^<2006-05-26T18:30:11Z#2>/:22443/' merge.lift
	#sed -i 's/^<2006-07-26T18:42:41Z#5>/:22556/' merge.lift
	#sed -i 's/^<2006-07-26T18:52:26Z#3>/:22564/' merge.lift
	#sed -i 's/^<2006-11-02T19:41:08Z#10>/:23669/' merge.lift
	#sed -i 's/^<2007-06-26T18:19:58Z#2>/:23921/' merge.lift
	#sed -i 's/^<2007-08-01T18:30:51Z#6>/:24276/' merge.lift
	#sed -i 's/^<2007-12-10T18:31:51Z#6>/:24508/' merge.lift
	#sed -i 's/^<2008-08-08T15:35:46Z#3>/:25084/' merge.lift
	#sed -i 's/^<2012-02-10T14:58:12Z#5>/:25683/' merge.lift

final-git: recombined.fi merge.lift final.lift Makefile
	$(RM) -r final-git
	reposurgeon "verbose 1" "prefer git" \
		    "read <recombined.fi" "script merge.lift" "script final.lift" \
		    "fossils write >final.fo" "write >final.fi"
	reposurgeon "read <final.fi" "prefer git" "rebuild final-git"

	# cannot safely delete merged branches with reposurgeon so we do it with git here
	git --git-dir=final-git/.git branch -d master-coda.cvs
	git --git-dir=final-git/.git branch -d master-lwp.cvs
	git --git-dir=final-git/.git branch -d master-lwp
	git --git-dir=final-git/.git branch -d master-rpc2.cvs
	git --git-dir=final-git/.git branch -d master-rpc2
	git --git-dir=final-git/.git branch -d master-rvm.cvs
	git --git-dir=final-git/.git branch -d master-rvm

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

