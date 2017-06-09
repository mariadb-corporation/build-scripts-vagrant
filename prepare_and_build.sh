#!/bin/bash

set -x

export work_dir=`pwd`
export MDBCI_VM_PATH=$HOME/vms; mkdir -p $MDBCI_VM_PATH
export target=`echo $target | sed "s/ //g"`

#cd ~/mdbci

export provider=`$HOME/mdbci/mdbci show provider $box --silent 2> /dev/null`
export name="$box-$JOB_NAME-$BUILD_NUMBER"
export name=`echo $name | sed "s|/|-|g"`

export platform=`$HOME/mdbci/mdbci show boxinfo --box-name=$box --field='platform' --silent`
export platform_version=`$HOME/mdbci/mdbci show boxinfo --box-name=$box --field='platform_version' --silent`

if [ "$try_already_running" == "yes" ]; then
	export name=$box$product_name
	export snapshot_lock_file=$MDBCI_VM_PATH/${name}_snapshot_lock
	while [ -f $snapshot_lock_file ]
	do
        	echo "snapshot is locked, waiting ..."
	        sleep 5
	done

	echo $JOB_NAME-$BUILD_NUMBER > $snapshot_lock_file
	$HOME/mdbci/mdbci snapshot revert --path-to-nodes $name --snapshot-name clean
	if [ $? == 0 ]; then
		export already_running="ok"
	fi
fi

if [ "$already_running" != "ok" ]; then

	cp ~/build-scripts/build.$provider.json.template $MDBCI_VM_PATH/$name.json

	sed -i "s/###box###/$box/g" $MDBCI_VM_PATH/$name.json

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
	$HOME/mdbci/mdbci --override --template $MDBCI_VM_PATH/$name.json generate $name
	$HOME/mdbci/mdbci up --attempts=1 $name
	if [ $? != 0 ] ; then
		echo "Error starting VM"
		vagrant destroy -f
		rm ~/vagrant_lock
		exit 1
	fi
	cp  ~/build-scripts/team_keys .
	$HOME/mdbci/mdbci public_keys --key team_keys --silent $name
fi
export sshuser=`$HOME/mdbci/mdbci ssh --command 'whoami' --silent $name/build 2> /dev/null`

# get VM info
export IP=`$HOME/mdbci/mdbci show network $name/build --silent 2> /dev/null`
export sshkey=`$HOME/mdbci/mdbci show keyfile $name/build --silent 2> /dev/null | sed 's/"//g'`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=120 "
export sshopt="$scpopt $sshuser@$IP"

rm ~/vagrant_lock

# running build
cd $work_dir
~/build-scripts/build.sh
res=$?
cd $MDBCI_VM_PATH/$name
if [ "$try_already_running" == "yes" ] ; then
	rm $snapshot_lock_file
fi
if [[ "$do_not_destroy_vm" != "yes" && "$try_already_running" != "yes" ]] ; then
	vagrant destroy -f
	cd ..
	rm -rf $name
	rm -rf $name.json
fi
exit $res

#fi

