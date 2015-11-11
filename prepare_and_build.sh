#!/bin/bash

set -x

export work_dir=`pwd`
export target=`echo $target | sed "s/ //g"`

#genereting json file 

#kostyl : PPC64 build
echo $box | grep "ppc64"
if [ $? == 0 ] ; then
	export sshuser="ec2-user"
	export IP=`cat ~/build-scripts/ppc_ip/$box`
	export sshkey="$HOME/build-scripts/ppc_key/$box"
	export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
	export sshopt="$scpopt $sshuser@$IP"

#	sudo ./start_vpn.sh

	~/build-scripts/build.sh
#        sudo killall openconnect
	
else

cd ~/mdbci

provider=`./mdbci show provider $box --silent 2> /dev/null`
datestr=`date +%Y%m%d-%H%M`
name=`echo build_$box_$datestr`
cp ~/build-scripts/build.$provider.json.template ~/mdbci/$name.json

sed -i "s/###box###/$box/g" ~/mdbci/$name.json

while [ -f ~/vagrant_lock ]
do
	sleep 5
done
touch ~/vagrant_lock

# destroying existing box
if [ -d "$name" ]; then
	cd $name
	vagrant destroy -f
	cd ..
fi

# starting VM for build
./mdbci --override --template ~/mdbci/$name.json generate $name
./mdbci up --attempts=4 $name
if [ $? != 0 ] ; then
	echo "Error starting VM"
	vagrant destroy -f
	rm ~/vagrant_lock
	exit 1
fi

export sshuser=`./mdbci ssh --command 'whoami' --silent $name/build 2> /dev/null`

# get VM info
export IP=`./mdbci show network $name/build --silent 2> /dev/null`
export sshkey=`./mdbci show keyfile $name/build --silent 2> /dev/null`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
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

fi
