#!/bin/bash

set -x

export work_dir=`pwd`
export target=`echo $target | sed "s/ //g"`

cd ~/mdbci

provider=`./mdbci show provider $box --silent 2> /dev/null`
name="$box-$JOB_NAME-$BUILD_NUMBER"
name=`echo $name | sed "s|/|-|g"`

export platform=`./mdbci show boxinfo --box-name=$box --field='platform' --silent`
export platform_version=`./mdbci show boxinfo --box-name=$box --field='platform_version' --silent`

cp ~/build-scripts/build.$provider.json.template ~/mdbci/$name.json

sed -i "s/###box###/$box/g" ~/mdbci/$name.json

while [ -f ~/vagrant_lock ]
do
	sleep 5
done
touch ~/vagrant_lock
echo $JOB_NAME-$BUILD_NUMBER >> ~/vagrant_lock

# destroying existing box
if [ -d "$name" ]; then
	cd $name
	vagrant destroy -f
	cd ..
fi

# starting VM for build
./mdbci --override --template $name.json generate $name
./mdbci up --attempts=1 $name
if [ $? != 0 ] ; then
	echo "Error starting VM"
	vagrant destroy -f
	rm ~/vagrant_lock
	exit 1
fi
cp  ~/build-scripts/team_keys .
./mdbci public_keys --key team_keys --silent $name
export sshuser=`./mdbci ssh --command 'whoami' --silent $name/build 2> /dev/null`

# get VM info
export IP=`./mdbci show network $name/build --silent 2> /dev/null`
export sshkey=`./mdbci show keyfile $name/build --silent 2> /dev/null | sed 's/"//g'`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=120 "
export sshopt="$scpopt $sshuser@$IP"

rm ~/vagrant_lock

# rinning build
cd $work_dir
~/build-scripts/build.sh
res=$?
cd ~/mdbci/$name
if [ "x$do_not_destroy_vm" != "xyes" ] ; then
	vagrant destroy -f
	cd ..
	rm -rf $name
	rm -rf $name.json
fi
exit $res

#fi

