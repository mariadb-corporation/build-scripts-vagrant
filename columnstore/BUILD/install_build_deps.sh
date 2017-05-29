#!/bin/bash

# Do the real building work. This script is executed on build VM and
# requires a working installation of CMake.


command -v apt-get

if [ $? -e 0 ]
then
  # DEB-based distro

  sudo apt-get update
  sudo apt-get install -y --force-yes build-essential automake \
      libboost-all-dev bison cmake libncurses5-dev libreadline-dev \
      libperl-dev libssl-dev libxml2-dev libkrb5-dev flex
else
  ## RPM-based distro
  command -v yum

  if [ $? -ne 0 ]
  then
    # We need zypper here
    sudo zypper -n install libxml2-devel cmake git automake flex autoconf rpm-build krb5-devel 
    sudo zypper -n install gcc gcc-c++ ncurses-devel bison glibc-devel libgcc_s1 perl \
       make libtool libopenssl-devel libaio libaio-devel flex libcurl-devel \
       pcre-devel git wget tcl libuuid-devel \
       xz-devel sqlite3 sqlite3-devel pkg-config lua lua-devel 
  else
    # YUM!
    sudo yum clean all
    sudo yum groupinstall -y --nogpgcheck "Development Tools"
    sudo yum install -y --nogpgcheck bison ncurses-devel readline-devel perl-devel openssl-devel cmake libxml2-devel 

  fi

fi

# cmake
wget http://max-tst-01.mariadb.com/ci-repository/cmake-3.7.1-Linux-x86_64.tar.gz --no-check-certificate
if [ $? != 0 ] ; then
    echo "CMake can not be downloaded from Maxscale build server, trying from cmake.org"
    wget https://cmake.org/files/v3.7/cmake-3.7.1-Linux-x86_64.tar.gz --no-check-certificate
    sudo tar xzvf cmake-3.7.1-Linux-x86_64.tar.gz -C /usr/ --strip-components=1
fi

cmake_version=`cmake --version | grep "cmake version" | awk '{ print $3 }'`
if [ "$cmake_version" \< "3.7.1" ] ; then
    echo "cmake does not work! Trying to build from source"
    wget https://cmake.org/files/v3.7/cmake-3.7.1.tar.gz --no-check-certificate
    tar xzvf cmake-3.7.1.tar.gz
    cd cmake-3.7.1

    ./bootstrap
    gmake
    sudo make install
    cd ..
fi

cd /usr/

sudo wget http://max-tst-01.mariadb.com/ci-repository/boost_1_55_0.tar.gz
sudo tar zxvf boost_1_55_0.tar.gz
sudo cd boost_1_55_0
sudo ./bootstrap.sh --with-libraries=atomic,date_time,exception,filesystem,iostreams,locale,program_options,regex,signals,system,test,thread,timer,log --prefix=/usr
sudo ./b2 install

sudo ldconfig

