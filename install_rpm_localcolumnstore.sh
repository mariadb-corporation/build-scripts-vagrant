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
  sudo zypper -n install gcc gcc-c++ ncurses-devel bison glibc-devel libgcc_s1 perl \
       make libtool libopenssl-devel libaio libaio-devel flex libcurl-devel \
       pcre-devel git wget tcl libuuid-devel \
       xz-devel sqlite3 sqlite3-devel pkg-config lua lua-devel \
       rpm-build $install_cmake
else
  sudo yum clean all
  sudo yum groupinstall -y --nogpgcheck "Development Tools"
  sudo yum install -y --nogpgcheck bison ncurses-devel readline-devel perl-devel openssl-devel cmake libxml2-devel $install_cmake
fi

cd /usr/

sudo wget http://max-tst-01.mariadb.com/ci-repository/boost_1_55_0.tar.gz
sudo tar zxvf boost_1_55_0.tar.gz
sudo cd boost_1_55_0
sudo ./bootstrap.sh --with-libraries=atomic,date_time,exception,filesystem,iostreams,locale,program_options,regex,signals,system,test,thread,timer,log --prefix=/usr
sudo ./b2 install

sudo ldconfig

. ~/check_arch.sh


