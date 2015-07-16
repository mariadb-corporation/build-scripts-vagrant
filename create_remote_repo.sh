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

echo "copying distro_name.sh to $IP"
scp $scpopt -r ~/build-scripts/distro_name.sh $sshuser@$IP:./

echo "executing distro_name.sh on $IP"
distro_name=`ssh $sshopt "./distro_name.sh" | tr '\n' ' ' | sed "s/ //"`

echo $distro_name

if [ -n $distro_name ] ; then
  if [ "$distro_name" != "unknown" ] ; then
	ssh $sshopt "mkdir -p dest/dists/$distro_name/main/"
	scp $scpopt -r ~/repository/$target/mariadb-maxscale/ubuntu/dists/$distro_name/main/* $sshuser@$IP:./dest/dists/$distro_name/main/
  fi
fi 

echo "executing create_repo.sh on $IP"
ssh $sshopt "./create_repo.sh dest/ src/"

echo "cleaning ~/repo/$target/$image/"
rm -rf ~/repo/$target/$image/*

echo "copying repo from $image"
mkdir -p ~/repo/$target/$image
scp $scpopt -r $sshuser@$IP:dest/* ~/repo/$target/$image/


