#!/bin/bash

set -x

export work_dir=`pwd`

export old_target=`echo $old_target | sed "s/?//g"`

cd ~/mdbci

provider=`./mdbci show provider $box --silent 2> /dev/null`
name=$box-$JOB_NAME-$BUILD_NUMBER
name=`echo $name | sed "s|/|-|g"`
cp ~/build-scripts/install.$provider.json ~/mdbci/$name.json

sed -i "s/###box###/$box/g" ~/mdbci/$name.json

while [ -f ~/vagrant_lock ]
do
	sleep 5
done
touch ~/vagrant_lock
echo $JOB_NAME-$BUILD_NUMBER >> ~/vagrant_lock

# destroying existing box
cd ~/mdbci
if [ -d "install_$box" ]; then
	cd $name
	vagrant destroy -f
	cd ..
fi

cd $work_dir
~/mdbci-repository-config/generate_all.sh repo.d
~/mdbci-repository-config/maxscale-ci.sh $old_target repo.d $ci_url_suffix
if [ -n "$repo_user" ] ; then
        sed -i "s|http://|http://$repo_user:$repo_password@|" repo.d/maxscale/*.json
        sed -i "s|https://|https://$repo_user:$repo_password@|" repo.d/maxscale/*.json
fi

cd ~/mdbci

# starting VM for build
./mdbci --override --template $name.json --repo-dir $work_dir/repo.d generate $name 
./mdbci up $name --attempts=1
if [ $? != 0 ] ; then
	./mdbci ssh --command "ls" $name
        if [ $? != 0 ] ; then
		echo "Error starting VM"
		cd $name
		if [ "x$do_not_destroy_vm" != "xyes" ] ; then
			vagrant destroy -f
		fi
		rm ~/vagrant_lock
		exit 1
	fi
fi

rm ~/vagrant_lock


cd $work_dir

cd ~/mdbci

#install MariaDB
./mdbci setup_repo --product $product --product-version $version $name/maxscale
./mdbci install_product --product $product $version $name/maxscale


# get VM info
export sshuser=`./mdbci ssh --command 'whoami' --silent $name/maxscale 2> /dev/null`
export IP=`./mdbci show network $name/maxscale --silent 2> /dev/null`
export sshkey=`./mdbci show keyfile $name/maxscale --silent 2> /dev/null | sed 's/"//g'`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=120 "
export sshopt="$scpopt $sshuser@$IP"

cd $work_dir

ssh $sshopt "mkdir maxscale-system-test"
scp $scpopt -r * $sshuser@$IP:~/maxscale-system-test

. ~/build-scripts/test/configure_log_dir.sh

echo "Installing deps and start servers"
ssh $sshopt "cd ~/maxscale-system-test/local_tests/; ./install_rpm_local.sh; ./start_multiple_mariadb.sh"
echo "building tests"
ssh $sshopt "cd ~/maxscale-system-test; cmake .; make"
echo "running tests"
ssh $sshopt "cd ~/maxscale-system-test; . ./local_tests/set_env_local.sh; ctest -L REPL_BACKEND -LE BREAKS_REPL -VV"


mkdir -p $logs_publish_dir
scp $scpopt -r $sshuser@$IP:~/maxscale-system-test/LOGS $logs_publish_dir
chmod a+r $logs_publish_dir/*

cd ~/mdbci/$name
if [ "x$do_not_destroy_vm" != "xyes" ] ; then
	vagrant destroy -f
fi
exit $res
