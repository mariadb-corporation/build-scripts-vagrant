#!/bin/bash
set -x
cd $dir
export MDBCI_VM_PATH=$HOME/vms; mkdir -p $MDBCI_VM_PATH
~/mdbci/repository-config/generate_all.sh repo.d
if [ "$debug_mode" != "debug" ] ; then
	~/mdbci/repository-config/maxscale-ci.sh $target repo.d $ci_url_suffix
fi

export repo_dir=$dir/repo.d/

if [ -n "$repo_user" ] ; then
	sed -i "s|http://|http://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
        sed -i "s|https://|https://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
fi

echo "box: $box"
echo "template: $template"

if [ "$box" == "predefined_template" ] ; then
	cp ~/build-scripts/test/templates/$template_name.json $MDBCI_VM_PATH/$name.json
else
	provider=`$HOME/mdbci/mdbci show provider $box --silent 2> /dev/null`
#	set -x
	template_raw="$HOME/build-scripts/test/debugtemplate.$provider.json"
	if [ "$debug_mode" != "debug" ] ; then
		if [ "x$big" != "xyes" ] ; then
			if [ -n "$machines_count" ] ; then
				template_raw=`~/build-scripts/test/generate_variable_machine_count_conf.sh $machines_count ~/build-scripts/test/template_performance.$provider.json ~/build-scripts/test/template_performance_node.$provider.json ~/build-scripts/test-setup-scripts/cnf_perf ~/build-scripts/test/template_performance_server.cnf`
			else
				template_raw="$HOME/build-scripts/test/template.$provider.json"
			fi
		else
        	        template_raw="$HOME/build-scripts/test/template_big.$provider.json"
		fi
	fi
	cp "$template_raw" "$MDBCI_VM_PATH/$name.json"
fi
#set +x
export galera_version=$version
#echo $version | grep "^10."
#if [ $? == 0 ] ; then
#	export galera_version="10.0"
#fi
#echo $version | grep "^10."
#if [ $? == 0 ] ; then
#        export galera_version="10.1"
#fi
set -x
sed -i "s/###galera_version###/$galera_version/g" $MDBCI_VM_PATH/$name.json
sed -i "s/###version###/$version/g" $MDBCI_VM_PATH/$name.json
sed -i "s/###product###/$product/g" $MDBCI_VM_PATH/$name.json
sed -i "s/###box###/$box/g" $MDBCI_VM_PATH/$name.json
sed -i "s/###target###/$target/g" $MDBCI_VM_PATH/$name.json
if [ "$product" == "mysql" ] ; then
	sed -i "s|/cnf|/cnf/mysql56|g" $MDBCI_VM_PATH/$name.json
fi

if [ "$vm_memory" != "" ] ; then
        sed -i "s|\"2048\"|\"$vm_memory\"|g" $MDBCI_VM_PATH/$name.json
fi


set +x
##cd ~/mdbci/
mkdir -p $MDBCI_VM_PATH/$name
cd $MDBCI_VM_PATH/$name
vagrant destroy -f
cd $dir
set -x
$HOME/mdbci/mdbci --override --template  $MDBCI_VM_PATH/$name.json --repo-dir $repo_dir generate $name
set +x
while [ -f ~/vagrant_lock ]
do
	echo "vagrant is locked, waiting ..."
	sleep 5
done
touch ~/vagrant_lock
echo $JOB_NAME-$BUILD_NUMBER >> ~/vagrant_lock

echo "running vagrant up $provider"

$HOME/mdbci/mdbci up $name --attempts 3
if [ $? != 0 ]; then
	echo "Error creating configuration"
	exit 1
fi

cp ~/build-scripts/team_keys .
$HOME/mdbci/mdbci  public_keys --key team_keys $name
