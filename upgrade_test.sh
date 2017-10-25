#!/bin/bash

set -x
export MDBCI_VM_PATH=$HOME/vms; mkdir -p $MDBCI_VM_PATH

if [ $run_upgrade_test == "no" ] ; then
	exit 0
fi

export work_dir=`pwd`

export old_target=`echo $old_target | sed "s/?//g"`
export new_target=`echo $new_target | sed "s/?//g"`

provider=`$HOME/mdbci/mdbci show provider $box --silent 2> /dev/null`
name=$box-$JOB_NAME-$BUILD_NUMBER
name=`echo $name | sed "s|/|-|g"`
cp ~/build-scripts/install.$provider.json $MDBCI_VM_PATH/$name.json

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
	cd $work_dir
fi

~/mdbci/repository-config/generate_all.sh repo.d
~/mdbci/repository-config/maxscale-ci.sh $old_target repo.d $ci_url_suffix
rm -rf repo.d/maxscale-release
if [ -n "$repo_key" ] ; then
        sed -i "s|.*repo_key.*|   \"repo_key\": \t\t\"$repo_key\",|" repo.d/maxscale/*
fi

if [ -n "$repo_user" ] ; then
        sed -i "s|http://|http://$repo_user:$repo_password@|" repo.d/maxscale/*.json
        sed -i "s|https://|https://$repo_user:$repo_password@|" repo.d/maxscale/*.json
fi

# starting VM for build
$HOME/mdbci/mdbci --override --template $MDBCI_VM_PATH/$name.json --repo-dir $work_dir/repo.d generate $name 
$HOME/mdbci/mdbci up $name --attempts=1
if [ $? != 0 ] ; then
        if [ $? != 0 ] ; then
		echo "Error starting VM"
		cd $MDBCI_VM_PATH/$name
		if [ "x$do_not_destroy_vm" != "xyes" ] ; then
			vagrant destroy -f
		fi
		cd $work_dir
		rm ~/vagrant_lock
		exit 1
	fi
fi

rm ~/vagrant_lock


rm -rf repo.d
~/mdbci/repository-config/generate_all.sh repo.d
~/mdbci/repository-config/maxscale-ci.sh $new_target repo.d $ci_url_suffix
rm -rf repo.d/maxscale-release
if [ -n "$repo_key" ] ; then
        sed -i "s|.*repo_key.*|   \"repo_key\": \t\t\"$repo_key\",|" repo.d/maxscale/*
fi

if [ -n "$repo_user" ] ; then
        sed -i "s|http://|http://$repo_user:$repo_password@|" repo.d/maxscale/*.json
fi


#cd ~/mdbci

$HOME/mdbci/mdbci setup_repo --product maxscale --repo-dir $work_dir/repo.d $name/maxscale
$HOME/mdbci/mdbci install_product --product maxscale $name/maxscale

res=$?

# get VM info
export sshuser=`$HOME/mdbci/mdbci ssh --command 'whoami' --silent $name/maxscale 2> /dev/null`
export IP=`$HOME/mdbci/mdbci show network $name/maxscale --silent 2> /dev/null`
export sshkey=`$HOME/mdbci/mdbci show keyfile $name/maxscale --silent 2> /dev/null | sed 's/"//g'`
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=120 "
export sshopt="$scpopt $sshuser@$IP"

if [ x"$cnf_file" == x ] ; then
        export cnf_file="maxscale.cnf.minimum"
fi


scp $scpopt ~/build-scripts/$cnf_file $sshuser@$IP:~/

. ~/build-scripts/test/configure_log_dir.sh

#maxscale_exe=`$HOME/mdbci/mdbci ssh --command 'ls /etc/init.d/maxscale 2> /dev/null | tr -cd "[:print:]"' $name/maxscale  --silent 2> /dev/null`
#echo $maxscale_exe | grep -i "maxscale"
$HOME/mdbci/mdbci ssh --command 'service --help' $name/maxscale
if [ $? == 0 ] ; then
	maxscale_start_cmd="sudo service maxscale start"
else
        $HOME/mdbci/mdbci ssh --command 'echo \"/usr/bin/maxscale 2> /dev/null &\" > maxscale_start.sh; echo \"disown\" >> maxscale_start.sh; chmod a+x maxscale_start.sh' $name/maxscale --silent
	maxscale_start_cmd="sudo ./maxscale_start.sh 2> /dev/null &"
fi



ssh $sshopt "sudo cp $cnf_file /etc/maxscale.cnf"
ssh $sshopt "$maxscale_start_cmd" &
pid_to_kill=$!
#ssh $sshopt 'sudo /etc/init.d/maxscale start'
sleep 10

ssh $sshopt $maxadmin_command
if [ $? != 0 ] ; then
	echo "Maxadmin executing error"
	res=1
fi
maxadmin_out=`ssh $sshopt $maxadmin_command`
echo $maxadmin_out | grep "CLI"
if [ $? != 0 ] ; then
	echo "CLI service is not found in maxadmin output"
        res=1
fi
echo $maxadmin_out | grep "Started"
if [ $? != 0 ] ; then
	echo "'Started' is not found in the CLI service description"
        res=1
fi

mkdir -p $logs_publish_dir
scp $scpopt $sshuser@$IP:/var/log/maxscale/* $logs_publish_dir
chmod a+r $logs_publish_dir/*

if [ "x$do_not_destroy_vm" != "xyes" ] ; then
	cd $MDBCI_VM_PATH/$name
	vagrant destroy -f
	cd $work_dir
fi
kill $pid_to_kill
exit $res
