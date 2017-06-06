#!/bin/bash

dir=`pwd`
export MDBCI_VM_PATH=$HOME/vms; mkdir -p $MDBCI_VM_PATH
export target=`echo $target | sed "s/ //g"`
export repo_dir=$dir/repo.d/

$HOME/mdbci/mdbci-repository-config/generate_all.sh repo.d
$HOME/mdbci/mdbci-repository-config/maxscale-ci.sh $target repo.d $ci_url_suffix

##cd ~/mdbci/
provider=`$HOME/mdbci/mdbci show provider $box --silent 2> /dev/null`
name=$box-$JOB_NAME-$BUILD_NUMBER
cp ~/build-scripts/install.$provider.json $MDBCI_VM_PATH/$name.json

sed -i "s/###box###/$box/g" $MDBCI_VM_PATH/$name.json
sed -i "s/###target###/$target/g" $MDBCI_VM_PATH/$name.json
##cd ~/mdbci/
mkdir -p $MDBCI_VM_PATH/$name
cd $MDBCI_VM_PATH/$name
vagrant destroy -f
cd $dir
$HOME/mdbci/mdbci --override --template $MDBCI_VM_PATH/$name.json --repo-dir $repo_dir generate $name

while [ -f ~/vagrant_lock ]
do
	echo "vagrant is locked, waiting ..."
	sleep 5
done
touch ~/vagrant_lock
echo $JOB_NAME-$BUILD_NUMBER >> ~/vagrant_lock

echo "running vagrant up $provider"
$HOME/mdbci/mdbci up $name
res=$?
echo "mdbci up returned $res"
rm ~/vagrant_lock

cd $MDBCI_VM_PATH/$name
if [ "$do_not_destroy_vm" != "yes" ] ; then
	vagrant destroy -f
fi

cd $dir
rm -rf $MDBCI_VM_PATH/$name
rm -rf $MDBCI_VM_PATH/$name.json
exit $res
