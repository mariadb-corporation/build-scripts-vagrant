#!/bin/bash

# Do the real building work. This script is executed on build VM and
# requires a working installation of CMake.

cd $work_dir

# Check if CMake needs to be installed
command -v cmake || install_cmake="cmake"

command -v yum

if [ $? -ne 0 ]
then
  sudo zypper -n install gcc-c++ libxml2-devel cmake git automake flex autoconf rpm-build krb5-devel $install_cmake
else
  sudo yum clean all
  sudo yum groupinstall y --nogpgcheck "Development Tools"
  sudo yum install y --nogpgcheck bison ncurses-devel readline-devel perl-devel openssl-devel cmake libxml2-devel $install_cmake
fi

cd /usr/

sudo wget http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz
sudo tar zxvf boost_1_55_0.tar.gz
sudo cd boost_1_55_0
sudo ./bootstrap.sh --with-libraries=atomic,date_time,exception,filesystem,iostreams,locale,program_options,regex,signals,system,test,thread,timer,log --prefix=/usr
sudo ./b2 install

sudo ldconfig

. ~/check_arch.sh


