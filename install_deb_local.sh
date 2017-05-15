#!/bin/bash 

# do the real building work
# this script is executed on build VM

cd $work_dir

# Check if CMake needs to be installed
command -v cmake || install_cmake="cmake"

. ~/check_arch.sh

set -x

sudo apt-get update

sudo apt-get install -y --force-yes dpkg-dev git gcc g++ ncurses-dev bison \
     build-essential libssl-dev libaio-dev perl make libtool libcurl4-openssl-dev \
     libpcre3-dev flex tcl libeditline-dev uuid-dev liblzma-dev libsqlite3-dev \
     sqlite3 liblua5.1 liblua5.1-dev libmicrohttpd-dev

if [ $remove_strip == "yes" ] ; then
        sudo rm -rf /usr/bin/strip
        sudo touch /usr/bin/strip
        sudo chmod a+x /usr/bin/strip
fi 

mkdir rabbit
cd rabbit
git clone https://github.com/alanxz/rabbitmq-c.git
if [ $? != 0 ] ; then
	echo "Error cloning rabbitmq-c"
	exit 1
fi
cd rabbitmq-c
git checkout v0.7.1
cmake .  -DCMAKE_C_FLAGS=-fPIC -DBUILD_SHARED_LIBS=N -DCMAKE_INSTALL_PREFIX=/usr
sudo make install
cd ../../

# Jansson
git clone https://github.com/akheron/jansson.git
if [ $? != 0 ] ; then
    echo "Error cloning jansson"
    exit 1
fi

mkdir -p jansson/build
pushd jansson/build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_FLAGS=-fPIC
make
sudo make install
popd

# Avro C API
wget http://mirror.netinch.com/pub/apache/avro/avro-1.8.2/c/avro-c-1.8.2.tar.gz
if [ $? != 0 ] ; then
    echo "Error getting avro-c"
    exit 1
fi

tar -axf avro-c-1.8.2.tar.gz
mkdir avro-c-1.8.2/build
pushd avro-c-1.8.2/build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_FLAGS=-fPIC -DCMAKE_CXX_FLAGS=-fPIC
make
sudo make install
popd

if [ "$use_mariadbd" == "yes" ] ; then
	wget --retry-connrefused $mariadbd_link
	sudo tar xzvf $mariadbd_file -C /usr/ --strip-components=1
	cmake_flags +=" -DERRMSG=/usr/share/english/errmsg.sys -DMYSQL_EMBEDDED_LIBRARIES=/usr/lib/"
fi
