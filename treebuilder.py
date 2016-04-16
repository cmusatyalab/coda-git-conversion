import argparse
import os
import re
import shutil
from subprocess import check_call, check_output
from collections import OrderedDict

parser = argparse.ArgumentParser()
parser.add_argument('--release')
args = parser.parse_args()

def load_tags(lift):
    tagmap = {}
    for line in open(lift):
        m = re.match('tag ([\w.+-]+) rename ([\w.+-]+)', line)
        if not m: continue

        cvs_tag, git_tag = m.groups()
        tagmap[git_tag] = cvs_tag
    return tagmap

CODA_TAGS = load_tags('coda.lift')
LWP_TAGS = load_tags('lwp.lift')
RPC2_TAGS = load_tags('rpc2.lift')
RVM_TAGS = load_tags('rvm.lift')

RELEASES = OrderedDict()
    
def rebuild_release(coda):
    lwp, rpc2, rvm = RELEASES[coda]
    coda_cvs = CODA_TAGS[coda]
    check_call(["cvs", "-d", "/coda/coda.cs.cmu.edu/project/coda/cvs", "-l", "-Q", "checkout", "-r", coda_cvs, 'coda'])

    if lwp != 'none':
        lwp_cvs = LWP_TAGS[lwp]
        check_call(["cvs", "-d", "/coda/coda.cs.cmu.edu/project/coda/cvs", "-l", "-Q", "checkout", "-r", lwp_cvs, 'lwp'])
        os.rename('lwp', 'coda/lib-src/lwp')

    if rpc2 != 'none':
        rpc2_cvs = RPC2_TAGS[rpc2]
        check_call(["cvs", "-d", "/coda/coda.cs.cmu.edu/project/coda/cvs", "-l", "-Q", "checkout", "-r", rpc2_cvs, 'rpc2'])
        os.rename('rpc2', 'coda/lib-src/rpc2')

    if rvm != 'none':
        rvm_cvs = RVM_TAGS[rvm]
        check_call(["cvs", "-d", "/coda/coda.cs.cmu.edu/project/coda/cvs", "-l", "-Q", "checkout", "-r", rvm_cvs, 'rvm'])
        os.rename('rvm', 'coda/lib-src/rvm')

    # cleanup crud
    for root, dirs, files in os.walk('coda'):
        if 'CVS' in dirs:
            dirs.remove('CVS')
            shutil.rmtree(os.path.join(root, 'CVS'))

        if '.cvsignore' in files:
            os.unlink(os.path.join(root, '.cvsignore'))

        if '.gitmodules' in files:
            os.unlink(os.path.join(root, '.gitmodules'))

    # make it look like a proper git checkout
    check_call(['rsync', '-a', "final-git/.git/", "coda/.git"])
    check_call(['git', '-C', "coda", "reset", "--mixed", "-q", coda_git])
    check_call('git -C coda ls-files | grep .cvsignore | git -C coda checkout-index -f --stdin', shell=True)
    check_call('git -C coda ls-files | grep .gitignore | git -C coda checkout-index -f --stdin', shell=True)
    check_call('git -C coda add .', shell=True)


for line in open('releases'):
    if line[0] == '#': continue

    coda_git, lwp_git, rpc2_git, rvm_git = line.split()
    RELEASES[coda_git] = (lwp_git, rpc2_git, rvm_git)

if args.release:
    rebuild_release(args.release)

else:
    for coda_git in RELEASES:
        print("Building release: {}".format(coda_git))
        rebuild_release(coda_git)

        out = check_output('git -C coda status', shell=True)
        out += '\n'
        out += check_output(['git', '-C', 'coda', 'diff', '--patch-with-stat', '--minimal', '-C', '--find-copies-harder', '--irreversible-delete', coda_git])
        with open('reports/{}'.format(coda_git), 'w') as f:
            f.write(out)

        msg = """CVS: {} {}""".format(coda_git, ' '.join(r for r in RELEASES[coda_git] if r != 'none') or '')
        check_call(['git', '-C', 'coda-final', 'checkout', '-f', 'refs/tags/{}'.format(coda_git)])
        commit_date = check_output('git -C coda-final show -q --pretty=format:%ct', shell=True).strip()
        env = ['env',
            'GIT_DIR=coda-final/.git',
            'GIT_AUTHOR_DATE="{}"'.format(commit_date),
            'GIT_COMMITTER_DATE="{}"'.format(commit_date),
        ]
        check_call(env + ['git', '-C', 'coda', 'add', '.'])
        check_call(env + ['git', '-C', 'coda', 'commit', '-a', '-m', msg])

        env = ['env', 'GIT_DIR=coda-final/.git']
        check_call(env + ['git', '-C', 'coda', 'tag', '-f', '-s', '-m', msg, coda_git])

        shutil.rmtree('coda')

