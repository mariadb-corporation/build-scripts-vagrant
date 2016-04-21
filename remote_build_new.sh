#!/bin/bash

# this script copyies stuff to VM and run build on VM

set -x

echo "target is $target"
mkdir -p $pre_repo_dir/$target/SRC
mkdir -p $pre_repo_dir/$target/$image

export work_dir="workspace"
export orig_image=$image

echo $sshuser
echo $platform
echo $platform_version
export vm_setup_script="$platform"_"$platform_version".sh
scp $scpopt ~/build-scripts/vm_setup_scripts/$vm_setup_script $sshuser@$IP:./
ssh $sshopt "sudo ./$vm_setup_script"

ssh $sshopt "sudo rm -rf $work_dir"
echo "copying stuff to $image machine"
ssh $sshopt "mkdir -p $work_dir"

scp $scpopt -r ./* $sshuser@$IP:$work_dir/ 
if [ $? -ne 0 ] ; then
        echo "Error copying stuff to $image machine"
        exit 2
fi

scp $scpopt -r ./.git $sshuser@$IP:$work_dir/

if [ "$Coverity" == "yes" ] ; then
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
	build_script="build_rpm_local.sh"
	files="*.rpm"
	tars="_build/maxscale*.tar.gz"
else
	build_script="build_deb_local.sh"
	files="../*.deb"
	tars="_build/maxscale*.tar.gz"
fi

echo "run build on $image"
ssh $sshopt "export cmake_flags=\"$cmake_flags\"; export work_dir=\"$work_dir\"; export remove_strip=$remove_strip; export embedded_ver=$embedded_ver; export platform=$platform; export platform_version=$platform_version; ./$build_script"
if [ $? -ne 0 ] ; then
        echo "Error build on $image"
        exit 4
fi

if [ "$no_repo" != "yes" ] ; then
	echo "copying repo to the repo/$target/$image"
	scp $scpopt $sshuser@$IP:$work_dir/$files $pre_repo_dir/$target/$image
	scp $scpopt $sshuser@$IP:$work_dir/$tars $pre_repo_dir/$target/$image
fi

if [ "$Coverity" == "yes" ] ; then
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
