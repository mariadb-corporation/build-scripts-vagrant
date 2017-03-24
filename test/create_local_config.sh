#!/bin/bash

export version="10.1"
export product="mariadb"
export box="centos_7_docker"
export do_not_destroy_vm="yes"
export big="no"
export ci_url="http://max-tst-01.mariadb.com/ci-repository/"
export ci_url_suffix="mariadb-maxscale"
export repo_user=""
export repo_password=""
export logs_dir="$HOME/LOGS"
export vm_memory="512"

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
	exit 1
fi

. ~/build-scripts/test/configure_backend.sh
cd ~/mdbci
./mdbci snapshot take --path-to-nodes $name --snapshot-name clean
cd $dir
