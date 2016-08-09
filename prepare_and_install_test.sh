#!/bin/bash

set -x

export work_dir=`pwd`

cd ~/mdbci

provider=`./mdbci show provider $box --silent 2> /dev/null`
name=$box-$JOB_NAME-$BUILD_NUMBER
cp ~/build-scripts/build.$provider.json.template ~/mdbci/$name.json

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

# starting VM for build
./mdbci --override --template $name.json generate $name
./mdbci up $name
if [ $? != 0 ] ; then
	echo "Error starting VM"
	cd $name
	vagrant destroy -f
	rm ~/vagrant_lock
	exit 1
fi

cd ..
export sshuser=`./mdbci ssh --command 'whoami' --silent install_$box/build 2> /dev/null | tr -cd "[:print:]"`

# get VM info
export IP=`./mdbci show network $name/build --silent 2> /dev/null`
export sshkey=`./mdbci show keyfile $name/build --silent 2> /dev/null | sed 's/"//g'`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
export sshopt="$scpopt $sshuser@$IP"

rm ~/vagrant_lock

# rinning build
cd $work_dir
~/build-scripts/install_test.sh
res=$?
cd ~/mdbci/$name
if [ "x$do_not_destroy_vm" != "xyes" ] ; then
	vagrant destroy -f
fi
exit $res
