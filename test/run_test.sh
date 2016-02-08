#!/bin/bash

# $1 - "debug" means do not install Maxscale

rm -rf LOGS

date_str=`date +%Y%m%d-%H`
export logs_publish_dir="$HOME/LOGS/$date_str/$name/$target/"
mkdir -p $logs_publish_dir

echo $1
if [ "$1" != "debug" ] ; then
	cmake . -DBUILDNAME=$name
	make
#	sudo make install
fi
dir=`pwd`
whoami
echo $dir
~/mdbci-repository-config/generate_all.sh repo.d
if [ "$1" != "debug" ] ; then
	~/mdbci-repository-config/maxscale-ci.sh $target repo.d
fi

export repo_dir=$dir/repo.d/

echo "box: $box"
echo "template: $template"
cd ~/mdbci/

if [ "$box" == "predefined_template" ] ; then
	cp ~/build-scripts/test/templates/$template_name.json ~/mdbci/$name.json
else
	provider=`./mdbci show provider $box --silent 2> /dev/null`
#	set -x
	if [ "$1" != "debug" ] ; then
		if [ "x$big" != "xyes" ] ; then
			cp ~/build-scripts/test/template.$provider.json ~/mdbci/$name.json
		else
        	        cp ~/build-scripts/test/template_big.$provider.json ~/mdbci/$name.json
		fi
	else
        	cp ~/build-scripts/test/debugtemplate.$provider.json ~/mdbci/$name.json
	fi
fi
#set +x
export galera_version=5.5
#echo $version | grep "^10."
#if [ $? == 0 ] ; then
#	export galera_version="10.0"
#fi
#echo $version | grep "^10."
#if [ $? == 0 ] ; then
#        export galera_version="10.1"
#fi

sed -i "s/###galera_version###/$galera_version/g" ~/mdbci/$name.json
sed -i "s/###version###/$version/g" ~/mdbci/$name.json
sed -i "s/###product###/$product/g" ~/mdbci/$name.json
sed -i "s/###box###/$box/g" ~/mdbci/$name.json
sed -i "s/###target###/$target/g" ~/mdbci/$name.json
cd ~/mdbci/
mkdir -p $name
cd $name
vagrant destroy -f
cd ..
set -x
./mdbci --override --template $name.json --repo-dir $repo_dir generate $name
set +x
while [ -f ~/vagrant_lock ]
do
	echo "vagrant is locked, waiting ..."
	sleep 5
done
touch ~/vagrant_lock

echo "running vagrant up $provider"
./mdbci up $name
cp ~/build-scripts/team_keys .
./mdbci  public_keys --key team_keys $name
if [ $? == 0 ] ; then
#rm ~/vagrant_lock

  . ~/build-scripts/test/set_env_vagrant.sh $name
  cd $name
  ~/build-scripts/test-setup-scripts/setup_repl.sh
  ~/build-scripts/test-setup-scripts/galera/setup_galera.sh

  ~/build-scripts/test/configure_core.sh

  cd $dir
rm ~/vagrant_lock
  if [ "$1" != "debug" ] ; then
    if [ x"$named_test" == "x" ] ; then
    	ctest -VV -D Nightly -I $test_set
    else
	./$named_test
    fi
  fi
#  date_str=`date +%Y%m%d-%H`
#  logs_dir="$HOME/LOGS/$date_str/$name/$target/"
#  mkdir -p $logs_dir
#  cp -r LOGS/* $logs_dir
  rsync -a LOGS $logs_publish_dir
  chmod a+r $logs_publish_dir/*

else
  vagrant destroy -f
  rm ~/vagrant_lock
  exit 1
fi  

cd ~/mdbci/$name
if [ "$do_not_destroy" != "yes" ] ; then
	vagrant destroy -f
fi
