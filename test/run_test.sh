#!/bin/bash
rm -rf LOGS
cmake .
make
sudo make install
dir=`pwd`
cp ~/build-scripts/test/template.json ~/mdbci/$name.json
sed -i "s/###version###/$version/g" ~/mdbci/$name.json
sed -i "s/###product###/$product/g" ~/mdbci/$name.json
sed -i "s/###box###/$box/g" ~/mdbci/$name.json
sed -i "s/###target###/$target/g" ~/mdbci/$name.json
cd ~/mdbci/
mkdir -p $name
cd $name
vagrant destroy -f
cd ..
./mdbci --override --template $name.json generate $name
cd $name

#sed -i "s/aws do |aws, override|/aws do |aws, override|\noverride.nfs.functional = false/" Vagrantfile

#vagrant up  --debug 
while [ -f /home/vagrant/vagrant_lock ]
do
	echo "vagrant is locked, waiting ..."
	sleep 5

done
touch /home/vagrant/vagrant_lock

#kostyl'
echo "rhel5 rhel6 rhel7 sles11 sles12 centos7 fedora19 fedora20 fedora21 fedora22 fedora23 deb_jessie ubuntu_vivid" | grep $box 
if [ $? == 0 ] ; then
        provider="--provider=aws"
else
        provider=""
fi

vagrant up $provider

if [ $? == 0 ] ; then
rm ~/vagrant_lock

  cd ..
  ./mdbci show network $name
  . ~/build-scripts/test/set_env_vagrant.sh $name
  cd $name
#  ../setup_root.sh
  ~/build-scripts/test-setup-scripts/setup_repl.sh
  ~/build-scripts/test-setup-scripts/galera/setup_galera.sh

  echo "show slave hosts" | mysql -uskysql -pskysql -h $repl_000

#  ~/build-scripts/test-scripts/install_for_test.sh
  ~/build-scripts/test-scripts/configure_core.sh
  #/usr/local/mariadb-maxscale/system-test/$test_name
  #disown

  cd $dir
  ctest -VV -D Nightly -I $test_set
else
  vagrant destroy -f
  rm ~/vagrant_lock
  exit 1
fi  

#sleep 1800
echo "done!"

cd ~/mdbci/$name
vagrant destroy -f
