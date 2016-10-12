#!/bin/bash

# $1 - "debug" means do not install Maxscale
ulimit -n
rm -rf LOGS

echo $target
echo $name

export target=`echo $target | sed "s/?//g"`
export value=`echo $value | sed "s/?//g"`

echo $target

. ~/build-scripts/test/configure_log_dir.sh

echo $1
export debug_mode=$1
if [ "$debug_mode" != "debug" ] ; then
	cmake . -DBUILDNAME=$name -DCMAKE_BUILD_TYPE=Debug
	make
fi

export dir=`pwd`
export repo_dir=$dir/repo.d/

~/build-scripts/test/create_config.sh

echo $target

if [ $? == 0 ] ; then

    . ~/build-scripts/test/configure_backend.sh
    if [ x"$named_test" == "x" ] ; then
    set -x
    ./check_backend
    if [ $? != 0 ]; then
	echo "Backend broken!"
	vagrant destroy -f
	rm ~/vagrant_lock
	exit 1
    fi
    ctest -VV -D Nightly $test_set
    set +x
    else
	./$named_test
    fi

    ~/build-scripts/test/copy_logs.sh
    rsync -a LOGS $logs_publish_dir
    chmod a+r $logs_publish_dir/*
else
  vagrant destroy -f
  rm ~/vagrant_lock
  exit 1
fi  

cd ~/mdbci/$name
if [ "$do_not_destroy_vm" != "yes" ] ; then
	vagrant destroy -f
fi
