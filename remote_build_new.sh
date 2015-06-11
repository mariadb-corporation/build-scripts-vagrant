#!/bin/bash

# this script copyies stuff to VM and run build on VM

set -x

echo "target is $target"
mkdir -p $pre_repo_dir/$target/SRC
mkdir -p $pre_repo_dir/$target/$image

export work_dir="workspace"
export orig_image=$image

scp $scpopt ~/build-scripts/vm_setup_scripts/$image.sh $sshuser@$IP:./
ssh $sshopt "sudo ./$image.sh"

ssh $sshopt "rm -rf $work_dir"
echo "copying stuff to $image machine"
ssh $sshopt "mkdir -p $work_dir"

scp $scpopt -r ./* $sshuser@$IP:$work_dir/ 
if [ $? -ne 0 ] ; then
        echo "Error copying stuff to $image machine"
        exit 2
fi

if [ "$Coverity" == "yes" ] ; then
	echo "Copying Coverity tools to VM"
        scp $scpopt -r  ~/build-scripts/coverity root@$IP:$work_dir
fi

image_type="RPM"
echo "copying build script to $image machine"
scp $scpopt  ~/build-scripts/*.sh  $sshuser@$IP:./ 
if [ $? -ne 0 ] ; then
    echo "Error copying build scripts to $image machine"
    exit 3
fi

if [ "$image_type" == "RPM" ] ; then
	build_script="build_rpm_local.sh"
	files="*.rpm"
else
	build_script="build_deb_local.sh"
	files="../*.deb"
fi

echo "run build on $image"
ssh $sshopt "export cmake_flags=\"$cmake_flags\"; export work_dir=\"$work_dir\"; ./$build_script"
if [ $? -ne 0 ] ; then
        echo "Error build on $image"
        exit 4
fi

echo "copying repo to the repo/$target/$image"
scp $scpopt $sshuser@$IP:$work_dir/$files $pre_repo_dir/$target/$image

if [ "$Coverity" == "yes" ] ; then
  scp $scpopt $sshuser@$IP:$work_dir/_build/maxscale.tgz .

curl --form token=DayIHFlOnCrr6Iizd98jVQ \
  --form email=timofey.turenko@skysql.com \
  --form file=@maxscale.tgz \
  --form version="1.0.2" \
  --form description="develop branch" \
  https://scan.coverity.com/builds?project=mariadb-corporation%2FMaxScale
fi
echo "package building for $target done!"

~/build-scripts/create_remote_repo.sh $image $IP $target
