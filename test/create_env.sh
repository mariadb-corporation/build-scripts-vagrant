#!/bin/bash

dir=`pwd`

export do_not_destroy_vm="yes"
~/build-scripts/test/run_test.sh debug

cd ~/mdbci
# get VM info
export sshuser=`./mdbci ssh --command 'whoami' --silent $name/maxscale 2> /dev/null`
export IP=`./mdbci show network $name/maxscale --silent 2> /dev/null`
export sshkey=`./mdbci show keyfile $name/maxscale --silent 2> /dev/null | sed 's/"//g'`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
export sshopt="$scpopt $sshuser@$IP"

export no_repo="yes"
export remove_strip="yes"

export platform=`./mdbci show boxinfo --box-name=$box --field='platform' --silent`
export platform_version=`./mdbci show boxinfo --box-name=$box --field='platform_version' --silent`

cd $dir
~/build-scripts/build.sh
res=$?
~/build-scripts/test/configure_core.sh
exit $res
