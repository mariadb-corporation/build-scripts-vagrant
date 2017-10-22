#!/bin/bash

set -x

export box=$box
export product=$product
export version=$version
export config_name="$box-$product-$version-permanent"

cd maxscale-system-test
export dir=`pwd`

. ~/build-scripts/test/configure_testset.sh
. ~/build-scripts/test/configure_log_dir.sh

#cd ~/mdbci 

function checkExitStatus {
    returnCode=$1
    errorMessage=$2
    lockFilePath=$3
    if [ "$returnCode" != 0 ]; then
        echo "$errorMesage"
        rm $lockFilePath
        echo "Snapshot lock file was deleted due to an error"
        exit 1
    fi     
}

# Setting snapshot_lock
export snapshot_lock_file=$HOME/mdbci/${config_name}_snapshot_lock
while [ -f $snapshot_lock_file ]
do
	echo "snapshot is locked, waiting ..."
	sleep 5
done
touch $snapshot_lock_file
echo $JOB_NAME-$BUILD_NUMBER >> $snapshot_lock_file

export repo_dir=$dir/repo.d/

$HOME/mdbci/mdbci snapshot revert --path-to-nodes $config_name --snapshot-name $snapshot_name

if [ $? != 0 ]; then
	cd $config_name
	vagrant destroy -f
	##cd ~/mdbci/scripts/
	./clean_vms.sh $config_name
	cd ..
    mkdir -p $HOME/mdbci/$config_name
	cd $dir
set -x
	export name_save=$name
	export name=$config_name
	~/build-scripts/test/create_config.sh
    checkExitStatus $? "Error creating configuration" $snapshot_lock_file
    . ~/build-scripts/test/configure_backend.sh
    export name=$name_save
	#cd ~/mdbci
	echo "Creating snapshot from new config"
set -x
	$HOME/mdbci/mdbci snapshot take --path-to-nodes $config_name --snapshot-name $snapshot_name
fi

cd $dir

. ~/build-scripts/test/set_env_vagrant.sh "$config_name"

~/mdbci/repository-config/maxscale-ci.sh $target repo.d $ci_url_suffix

if [ -n "$repo_user" ] ; then
        sed -i "s|http://|http://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
        sed -i "s|https://|https://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
fi

#cd ~/mdbci

$HOME/mdbci/mdbci sudo --command 'yum remove maxscale -y' $config_name/maxscale
$HOME/mdbci/mdbci sudo --command 'yum clean all' $config_name/maxscale

$HOME/mdbci/mdbci setup_repo --product maxscale $config_name/maxscale --repo-dir $repo_dir 
$HOME/mdbci/mdbci install_product --product maxscale $config_name/maxscale --repo-dir $repo_dir

checkExitStatus $? "Error installing Maxscale" $snapshot_lock_file

cd $dir
cmake . -DBUILDNAME=$JOB_NAME-$BUILD_NUMBER-$target
make

./check_backend --restart-galera

checkExitStatus $? "Failed to check backends" $snapshot_lock_file

ctest $test_set -VV -D Nightly

~/build-scripts/test/copy_logs.sh

# Removing snapshot_lock
rm $snapshot_lock_file
