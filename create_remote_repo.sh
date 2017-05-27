#!/bin/bash

set -x

echo "cleaning $IP"
ssh $sshopt "rm -rf dest; rm -rf src;"

echo " creating dirs on $IP"
ssh $sshopt "mkdir -p dest ; mkdir -p src"

echo "copying stuff to $IP"
scp $scpopt $pre_repo_dir/$target/$image/* $sshuser@$IP:src/

scp $scpopt -r ~/MariaDBManager-GPG-KEY.p* $sshuser@$IP:./
ssh $sshopt "gpg --import MariaDBManager-GPG-KEY.public"
ssh $sshopt "gpg --allow-secret-key-import --import MariaDBManager-GPG-KEY.private"

echo "copying create_repo.sh to $IP"
scp $scpopt -r ~/build-scripts/create_repo.sh $sshuser@$IP:./

distro_name=$platform_name

echo $distro_name

echo "executing create_repo.sh on $IP"
ssh $sshopt "export platform=$platform; export platform_version=$platform_version; ./create_repo.sh dest/ src/"
if [ $? != 0 ] ; then
	echo "Repo creation failed!"
	exit 1
fi

echo "cleaning ~/repo/$target/$image/"
rm -rf ~/repo/$target/$image/*

echo "copying repo from $image"
mkdir -p ~/repo/$target/$image
scp $scpopt -r $sshuser@$IP:dest/* ~/repo/$target/$image/
