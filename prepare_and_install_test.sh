#!/bin/bash

set -x

export work_dir=`pwd`

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

	~/build-scripts/install_test.sh
#        sudo killall openconnect
	
else

#kostyl'
echo "rhel5 rhel6 rhel7 sles11 sles12 centos7 fedora19 fedora20 fedora21 fedora22 fedora23 deb_jessie ubuntu_vivid" | grep $box 
if [ $? == 0 ] ; then
	cp ~/build-scripts/build.aws.json.template ~/mdbci/install_$box.json
	provider="--provider=aws"
else
	cp ~/build-scripts/build.json.template ~/mdbci/install_$box.json
	provider=""
fi
sed -i "s/###box###/$box/g" ~/mdbci/install_$box.json

while [ -f ~/vagrant_lock ]
do
	sleep 5
done
touch ~/vagrant_lock

# destroying existing box
cd ~/mdbci
if [ -d "install_$box" ]; then
	cd install_$box
	vagrant destroy -f
	cd ..
fi

# starting VM for build
./mdbci --override --template ~/mdbci/install_$box.json generate install_$box
cd install_$box
vagrant up $provider
if [ $? != 0 ] ; then
	echo "Error starting VM"
	vagrant destroy -f
	rm ~/vagrant_lock
	exit 1
fi

export sshuser=`vagrant ssh -c 'whoami' 2> /dev/null | tr -cd "[:print:]"`
cd ..

# get VM info
export IP=`./mdbci show network install_$box/default --silent 2> /dev/null`
export sshkey=`./mdbci show keyfile install_$box/default --silent 2> /dev/null`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
export sshopt="$scpopt $sshuser@$IP"

rm ~/vagrant_lock

# rinning build
cd $work_dir
~/build-scripts/install_test.sh
res=$?
cd ~/mdbci/install_$box
if [ "x$do_not_destroy_vm" != "xyes" ] ; then
	vagrant destroy -f
fi
exit $res

fi
