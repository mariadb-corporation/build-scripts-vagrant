#!/bin/bash

# this script copyies stuff to VM and run build on VM

set -x

echo "target is $target"
rm -rf $pre_repo_dir/$target/$image
mkdir -p $pre_repo_dir/$target/SRC
mkdir -p $pre_repo_dir/$target/$image

export work_dir="workspace"
export orig_image=$image

echo $sshuser
echo $platform
echo $platform_version

if [ "$already_running" != "ok" ]; then
	export vm_setup_script="$platform"_"$platform_version".sh
#	scp $scpopt ~/build-scripts/vm_setup_scripts/$vm_setup_script $sshuser@$IP:./
        scp $scpopt ~/build-scripts/vm_setup_scripts/* $sshuser@$IP:./

	ssh $sshopt "sudo ./$vm_setup_script"
fi

ssh $sshopt "sudo rm -rf $work_dir"
echo "copying stuff to $image machine"
ssh $sshopt "mkdir -p $work_dir"

scp $scpopt -r ./* $sshuser@$IP:$work_dir/ 
if [ $? -ne 0 ] ; then
        echo "Error copying stuff to $image machine"
        exit 2
fi

scp $scpopt -r ./.git $sshuser@$IP:$work_dir/

if [ "$coverity" == "yes" ] ; then
	echo "Copying Coverity tools to VM"
        scp $scpopt -r  ~/build-scripts/coverity $sshuser@$IP:$work_dir
fi

echo "copying build script to $image machine"
scp $scpopt  ~/build-scripts/*.sh  $sshuser@$IP:./ 
if [ $? -ne 0 ] ; then
    echo "Error copying build scripts to $image machine"
    exit 3
fi

if [ "$image_type" == "RPM" ] ; then
	build_script="build_rpm_local$product_name.sh"
	install_script="install_rpm_local$product_name.sh"
	files="*.rpm"
        if [ "$product_name" == "" ] ; then
		tars="maxscale*.tar.gz"
	else
		tars="$product_name*.tag.gz"
	fi
else
	build_script="build_deb_local$product_name.sh"
        install_script="install_deb_local$product_name.sh"
	files="../*.deb"
        if [ "$product_name" == "" ] ; then
		tars="maxscale*.tar.gz"
	else
		tars="$product_name*.tag.gz"
	fi
fi
if [ "$already_running" != "ok" ] ; then
	export already_running="false"
fi
export remote_build_cmd="export already_running=\"$already_running\"; \
	export use_mariadbd=\"$use_mariadbd\"; \
	export build_experimental=\"$build_experimental\"; \
	export cmake_flags=\"$cmake_flags\"; \
	export work_dir=\"$work_dir\"; \
	export remove_strip=\"$remove_strip\"; \
	export platform=\"$platform\"; \
	export platform_version=\"$platform_version\"; \
	export source=\"$source\"; \
	export value=\"$value\"; \
	export BUILD_TAG=\"$BUILD_TAG\"; \
	"

if [ "$already_running" != "ok" ]
then
	echo "install packages on $image"
	ssh $sshopt "$remote_build_cmd ./$install_script"
    installres=$?

    if [ $installres -ne 0 ]
    then
        exit $installres
    fi

    dir1=`pwd`
    cd ~/mdbci
    ./mdbci snapshot take --path-to-nodes $box --snapshot-name clean
    cd $dir1
else
	echo "already running VM, not installing deps"
fi

echo "run build on $image"
ssh $sshopt "$remote_build_cmd ./$build_script"
if [ $? -ne 0 ] ; then
        echo "Error build on $image"
        exit 4
fi

if [ "$no_repo" != "yes" ] ; then
	echo "copying repo to the repo/$target/$image"
	scp $scpopt $sshuser@$IP:$work_dir/$files $pre_repo_dir/$target/$image
	scp $scpopt $sshuser@$IP:$work_dir/$tars $pre_repo_dir/$target/$image
fi

if [ "$coverity" == "yes" ] ; then
  scp $scpopt $sshuser@$IP:$work_dir/_build/maxscale.tgz .

curl --form token=DayIHFlOnCrr6Iizd98jVQ \
  --form email=timofey.turenko@skysql.com \
  --form file=@maxscale.tgz \
  --form version="1.4.0" \
  --form description="develop branch" \
  https://scan.coverity.com/builds?project=mariadb-corporation%2FMaxScale
fi
echo "package building for $target done!"

if [ "$no_repo" != "yes" ] ; then
	~/build-scripts/create_remote_repo.sh $image $IP $target
fi
