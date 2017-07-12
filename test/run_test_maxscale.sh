#!/bin/bash

dir=`pwd`

ulimit -n
rm -rf LOGS

export target=`echo $target | sed "s/?//g"`
export name=`echo $name | sed "s/?//g"`
export value=`echo $value | sed "s/?//g"`

. ~/build-scripts/test/configure_testset.sh
. ~/build-scripts/test/configure_log_dir.sh

export dir=`pwd`
export repo_dir=$dir/repo.d/
export debug_mode="debug"
if [ "$local_backend" != "yes"  ] ; then
	~/build-scripts/test/create_config.sh
	res=$?
	if [ $res == 0 ] ; then
	    . ~/build-scripts/test/configure_backend.sh
	else
		exit 1
	fi
else
	#cd ~/mdbci
	provider=`$HOME/mdbci/mdbci show provider $box --silent 2> /dev/null`
	cp ~/build-scripts/install.$provider.json $MDBCI_VM_PATH/$name.json

	sed -i "s/###box###/$box/g" $MDBCI_VM_PATH/$name.json

	while [ -f ~/vagrant_lock ]
	do
        	sleep 5
	done
	touch ~/vagrant_lock
	echo $JOB_NAME-$BUILD_NUMBER >> ~/vagrant_lock

	# destroying existing box
	if [ -d "install_$box" ]; then
        	cd $MDBCI_VM_PATH/$name
	        vagrant destroy -f
        	cd $dir
	fi

	~/mdbci/repository-config/generate_all.sh repo.d
	~/mdbci/repository-config/maxscale-ci.sh $target repo.d $ci_url_suffix
	if [ -n "$repo_user" ] ; then
        	sed -i "s|http://|http://$repo_user:$repo_password@|" repo.d/maxscale/*.json
	        sed -i "s|https://|https://$repo_user:$repo_password@|" repo.d/maxscale/*.json
	fi

	# starting VM for build
	$HOME/mdbci/mdbci --override --template $name.json --repo-dir $work_dir/repo.d generate $name 
	$HOME/mdbci/mdbci up $name --attempts=1
	if [ $? != 0 ] ; then
	        if [ $? != 0 ] ; then
        	        echo "Error starting VM"
	                if [ "x$do_not_destroy_vm" != "xyes" ] ; then
				cd $MDBCI_VM_PATH/$name
				vagrant destroy -f
				cd $dir
                	fi
	                rm ~/vagrant_lock
        	        exit 1
	        fi
	fi

	rm ~/vagrant_lock
fi

. ~/build-scripts/test/set_env_vagrant.sh $name
#cd ~/mdbci
# get VM info
export sshuser=`$HOME/mdbci/mdbci ssh --command 'whoami' --silent $name/maxscale 2> /dev/null`
export IP=`$HOME/mdbci/mdbci show network $name/maxscale --silent 2> /dev/null`
export sshkey=`$HOME/mdbci/mdbci show keyfile $name/maxscale --silent 2> /dev/null | sed 's/"//g'`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
export sshopt="$scpopt $sshuser@$IP"

#export no_repo="yes"
export remove_strip="yes"

export platform=`$HOME/mdbci/mdbci show boxinfo --box-name=$box --field='platform' --silent`
export platform_version=`$HOME/mdbci/mdbci show boxinfo --box-name=$box --field='platform_version' --silent`

cd $dir
~/build-scripts/build_maxscale.sh
res=$?
if [ $res != 0 ] ; then
	echo "Maxscale build failed"
	exit 1
fi
~/build-scripts/test/configure_core.sh
#cd ~/mdbci
$HOME/mdbci/mdbci snapshot  take --path-to-nodes $name --snapshot-name clean
if [ $? != 0 ] ; then
	echo "Snapshot creation failed!"
fi

cd $dir

if [ $local_backend == "yes" ] ; then
	echo "Start servers"
	ssh $sshopt "cd ~/MaxScale/maxscale-system-test/local_tests/; ./start_multiple_mariadb.sh"
	echo "building tests"
	ssh $sshopt "cd ~/MaxScale/maxscale-system-test; cmake .; make"
	echo "running tests"
        if [ x"$named_test" == "x" ] ; then
		ssh $sshopt "cd ~/MaxScale/maxscale-system-test; . ./local_tests/set_env_local.sh; ctest $test_set -VV"
	else
                ssh $sshopt "cd ~/MaxScale/maxscale-system-test; . ./local_tests/set_env_local.sh; ./named_test"
	fi
	mkdir -p $logs_publish_dir
	scp $scpopt -r $sshuser@$IP:~/maxscale-system-test/LOGS $logs_publish_dir
	chmod a+r $logs_publish_dir/*
else
    ##cd ~/mdbci/
    #$HOME/mdbci/mdbci snapshot take --path-to-nodes $name --snapshot-name clean
    cd $dir/maxscale-system-test/
    cmake .
    make
    if [ x"$named_test" == "x" ] ; then
        set -x
        ./check_backend
        if [ $? != 0 ]; then
            echo "Backend broken!"
            if [ "$do_not_destroy_vm" != "yes" ] ; then
                cd $MDBCI_VM_PATH/$name
                vagrant destroy -f
		cd $dir
            fi
            rm ~/vagrant_lock
            exit 1
        fi
        ctest -VV -D Nightly $test_set
        set +x
    else
        ./$named_test
    fi

    ~/build-scripts/test/copy_logs.sh
fi

exit $res
