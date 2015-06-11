#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cd $work_dir

sudo yum install -y rpmdevtools
sudo yum install -y wget
sudo zypper -n install rpmdevtools
sudo zypper -n install wget
. ~/check_arch.sh

yum --version
if [ $? != 0 ] ; then
	sudo zypper -n install rpm-build
	zy=1
else
	sudo yum install -y rpm-build createrepo yum-utils
	zy=0
fi

wget  --retry-connrefused $mariadbd_link
sudo tar xzvf $mariadbd_file -C /usr/ --strip-components=1
cmake_flags+=" -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/ "


if [ $zy != 0 ] ; then
  sudo zypper -n install gcc gcc-c++ ncurses-devel bison glibc-devel cmake libgcc_s1 perl make libtool libopenssl-devel libaio libaio-devel 
  sudo zypper -n install librabbitmq-devel
  sudo zypper -n install libcurl-devel
  sudo zypper -n install pcre-devel
  cat /etc/*-release | grep "SUSE Linux Enterprise Server 11"
  if [ $? != 0 ] ; then 
    sudo zypper -n install libedit-devel
  fi

  sudo zypper -n install systemtap-sdt-devel
  wget $mariadbd_link
  tar xzvf $mariadbd_file -C /usr/ --strip-components=1
  cmake_flags+=" -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/ "

else
  sudo yum clean all 
  sudo yum install -y --skip-broken --nogpgcheck gcc gcc-c++ ncurses-devel bison glibc-devel libgcc perl make libtool openssl-devel libaio libaio-devel librabbitmq-devel libedit-devel
  sudo yum install -y --skip-broken --nogpgcheck libedit-devel
  sudo yum install -y --nogpgcheck libcurl-devel
  sudo yum install -y --nogpgcheck curl-devel
  sudo yum install -y --skip-broken --nogpgcheck systemtap-sdt-devel
  sudo yum install -y --nogpgcheck rpm-sign
  sudo yum install -y --nogpgcheck gnupg
  sudo yum install -y --nogpgcheck pcre-devel
# sudo yum install -y libaio 

  cat /etc/redhat-release | grep "release 5"
  if [[ $? == 0 ]] ; then
      sudo yum remove -y libedit-devel libedit
  fi
fi

mkdir _build
chmod -R a-w .
chmod u+w _build
cd _build
cmake ..  $cmake_flags 
if [ -d ../coverity ] ; then
  tar xzvf ../coverity/coverity_tool.tgz
  export PATH=$PATH:`pwd`/cov-analysis-linux64-7.6.0/bin/
  cov-build --dir cov-int make
  tar czvf maxscale.tgz cov-int
else
  make
fi
 
sudo make package

rm ../CMakeCache.txt
rm CMakeCache.txt


if [ "$BUILD_RABBITMQ" == "yes" ] ; then
  cmake ../rabbitmq_consumer/  $cmake_flags 
  sudo make package
fi

cd ..
chmod -R u+wr .
cp _build/*.rpm .

