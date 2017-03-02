#!/bin/bash 

# do the real building work
# this script is executed on build VM

cd $work_dir

# Check if CMake needs to be installed
command -v cmake || install_cmake="cmake"

. ~/check_arch.sh

set -x

sudo apt-get update

sudo apt-get install -y --force-yes build-essential automake \
	libboost-all-dev bison cmake libncurses5-dev libreadline-dev \
	libperl-dev libssl-dev libxml2-dev libkrb5-dev flex
if [ $remove_strip == "yes" ] ; then
        sudo rm -rf /usr/bin/strip
        sudo touch /usr/bin/strip
        sudo chmod a+x /usr/bin/strip
fi 


