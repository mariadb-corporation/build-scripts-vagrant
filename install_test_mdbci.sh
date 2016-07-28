#!/bin/bash

dir=`pwd`
export target=`echo $target | sed "s/ //g"`
export repo_dir=$dir/repo.d/

~/mdbci-repository-config/generate_all.sh repo.d
~/mdbci-repository-config/maxscale-ci.sh $target repo.d

cd ~/mdbci/
provider=`./mdbci show provider $box --silent 2> /dev/null`
datestr=`date +%Y%m%d-%H%M`
name="install_$box-$datestr"
cp ~/build-scripts/install.$provider.json ~/mdbci/$name.json

sed -i "s/###box###/$box/g" ~/mdbci/$name.json
sed -i "s/###target###/$target/g" ~/mdbci/$name.json
cd ~/mdbci/
mkdir -p $name
cd $name
vagrant destroy -f
cd ..
./mdbci --override --template $name.json --repo-dir $repo_dir generate $name

while [ -f ~/vagrant_lock ]
do
	echo "vagrant is locked, waiting ..."
	sleep 5
done
touch ~/vagrant_lock
echo $JOB_NAME-$BUILD_NUMBER >> ~/vagrant_lock

echo "running vagrant up $provider"
./mdbci up $name
res=$?
echo "mdbci up returned $res"
rm ~/vagrant_lock

cd ~/mdbci/$name
if [ "$do_not_destroy_vm" != "yes" ] ; then
	vagrant destroy -f
fi

cd ..
rm -rf $name
rm -rf $name.json
exit $res
