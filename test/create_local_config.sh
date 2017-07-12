#!/bin/bash

ulimit -n
rm -rf LOGS

target=$1
if [ "$target" == "" ] ; then
	export target="develop"
fi

name=$2
if [ "$name" == "" ] ; then
        export name="local_test"
fi

export target=`echo $target | sed "s/?//g"`
export name=`echo $name | sed "s/?//g"`

bdate=`date '+%Y%m%e-%H%M'`
export JOB_NAME="local-test-$date"
export BUILD_ID=$name
. ~/build-scripts/test/configure_log_dir.sh

export dir=`pwd`
export repo_dir=$dir/repo.d/

~/build-scripts/test/create_config.sh
if [ $? != 0 ] ; then
	echo "VM creation failed"
else
	. ~/build-scripts/test/configure_backend.sh
	#cd ~/mdbci
	$HOME/mdbci/mdbci snapshot take --path-to-nodes $name --snapshot-name clean
	cd $dir
fi