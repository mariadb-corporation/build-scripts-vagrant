#!/bin/bash

set -x
export MDBCI_VM_PATH=$HOME/vms; mkdir -p $MDBCI_VM_PATH

export work_dir=`pwd`

#cd ~/mdbci

provider=`$HOME/mdbci/mdbci show provider $box --silent 2> /dev/null`
name=$box-$JOB_NAME-$BUILD_NUMBER
name=`echo $name | sed "s|/|-|g"
cp ~/build-scripts/build.$provider.json.template $MDBCI_VM_PATH/$name.json

sed -i "s/###box###/$box/g" $MDBCI_VM_PATH/$name.json

while [ -f ~/vagrant_lock ]
do
	sleep 5
done
touch ~/vagrant_lock
echo $JOB_NAME-$BUILD_NUMBER >> ~/vagrant_lock

# destroying existing box
#cd ~/mdbci
if [ -d "install_$box" ]; then
	cd $MDBCI_VM_PATH/$name
	vagrant destroy -f
	cd ..
fi

# starting VM for build
$HOME/mdbci/mdbci --override --template $MDBCI_VM_PATH/$name.json generate $name
$HOME/mdbci/mdbci up $name
if [ $? != 0 ] ; then
	echo "Error starting VM"
	cd $MDBCI_VM_PATH/$name
	vagrant destroy -f
	rm ~/vagrant_lock
	exit 1
fi

cd ..
export sshuser=`$HOME/mdbci/mdbci ssh --command 'whoami' --silent install_$box/build 2> /dev/null | tr -cd "[:print:]"`

# get VM info
export IP=`$HOME/mdbci/mdbci show network $name/build --silent 2> /dev/null`
export sshkey=`$HOME/mdbci/mdbci show keyfile $name/build --silent 2> /dev/null | sed 's/"//g'`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
export sshopt="$scpopt $sshuser@$IP"

rm ~/vagrant_lock

# rinning build
cd $work_dir
~/build-scripts/install_test.sh
res=$?
cd $MDBCI_VM_PATH/$name
if [ "x$do_not_destroy_vm" != "xyes" ] ; then
	vagrant destroy -f
fi
exit $res
