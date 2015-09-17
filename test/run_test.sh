#!/bin/bash

set -x
rm -rf LOGS
cmake . -DBUILDNAME=$name

make
sudo make install
dir=`pwd`

~/mdbci-repository-config/generate_all.sh repo.d
~/mdbci-repository-config/maxscale-ci.sh $target repo.d
export repo_dir=$dir/repo.d/

. ~/build-scripts/test/get_provider

cp ~/build-scripts/test/$template ~/mdbci/$name.json
sed -i "s/###version###/$version/g" ~/mdbci/$name.json
sed -i "s/###product###/$product/g" ~/mdbci/$name.json
sed -i "s/###box###/$box/g" ~/mdbci/$name.json
sed -i "s/###target###/$target/g" ~/mdbci/$name.json
cd ~/mdbci/
mkdir -p $name
cd $name
vagrant destroy -f
cd ..
./mdbci --override --template $name.json --repo-dir $repo_dir generate $name
cd $name

while [ -f /home/vagrant/vagrant_lock ]
do
	echo "vagrant is locked, waiting ..."
	sleep 5

done
touch /home/vagrant/vagrant_lock

echo "running vagrant up $provider"
~/build-scripts/vagrant_up 

if [ $? == 0 ] ; then
rm ~/vagrant_lock

  cd ..
  ./mdbci show network $name
  . ~/build-scripts/test/set_env_vagrant.sh $name
env
  cd $name
#  ../setup_root.sh
  ~/build-scripts/test-setup-scripts/setup_repl.sh
  ~/build-scripts/test-setup-scripts/galera/setup_galera.sh

  echo "show slave hosts" | mysql -uskysql -pskysql -h $repl_000

  ~/build-scripts/test/configure_core.sh

  cd $dir
  ctest -VV -D Nightly -I $test_set
  date_str=`date +%Y%m%d-%H`
  logs_dir="/home/vagrant/LOGS/$date_str/$name/$target/"
  mkdir -p $logs_dir
  cp -r LOGS/* $logs_dir
  chmod a+r $logs_dir/*

else
  vagrant destroy -f
  rm ~/vagrant_lock
  exit 1
fi  

#sleep 1800
echo "done!"

cd ~/mdbci/$name
#vagrant destroy -f
