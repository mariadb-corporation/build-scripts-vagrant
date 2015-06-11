#!/bin/bash

export work_dir=`pwd`

#genereting json file 
cp ~/mdbci/build.json.template ~/mdbci/build_$box.json
sed -i "s/###box###/$box/g" ~/mdbci/build_$box.json

# destroying existing box
cd ~/mdbci
if [ -d "build_conf_$box" ]; then
	cd build_conf_$box
	vagrant destroy -f
	cd ..
fi

# starting VM for build
./mdbci --override --template ~/mdbci/build_$box.json generate build_conf_$box
cd build_conf_$box
vagrant up
cd ..

# get VM info
export IP=`./mdbci show network build_conf_$box/build --silent 2> /dev/null`
export sshkey=`./mdbci show keyfile build_conf_$box/build --silent 2> /dev/null`
export sshuser="vagrant"
export scpopt="-i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "
export sshopt="$scpopt $sshuser@$IP"

# rinning build
cd $work_dir
~/build-scripts/build.sh
