#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cd $work_dir

. ~/check_arch.sh

sudo apt-get update
sudo apt-get install -y dpkg-dev git

sudo apt-get install -y --force-yes cmake
sudo apt-get install -y --force-yes gcc g++ ncurses-dev bison build-essential libssl-dev libaio-dev perl make libtool 
#sudo apt-get install -y --force-yes librabbitmq-dev
sudo apt-get install -y --force-yes libcurl4-openssl-dev
sudo apt-get install -y --force-yes libpcre3-dev
sudo apt-get install -y --force-yes flex
#sudo apt-get install -y --force-yes flex
sudo apt-get install -y --force-yes tcl
sudo apt-get install -y --force-yes libeditline-dev
sudo apt-get install -y --force-yes uuid-dev
sudo apt-get install -y --force-yes liblzma-dev

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

# SQLite3
sudo apt-get install -y --force-yes libsqlite3-dev sqlite3

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
wget http://mirror.netinch.com/pub/apache/avro/avro-1.8.0/c/avro-c-1.8.0.tar.gz
if [ $? != 0 ] ; then
    echo "Error getting avro-c"
    exit 1
fi

tar -axf avro-c-1.8.0.tar.gz
mkdir avro-c-1.8.0/build
pushd avro-c-1.8.0/build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_FLAGS=-fPIC -DCMAKE_CXX_FLAGS=-fPIC
make
sudo make install
popd

if [ "$use_mariadbd" == "yes" ] ; then
	wget --retry-connrefused $mariadbd_link
	sudo tar xzvf $mariadbd_file -C /usr/ --strip-components=1
	cmake_flags +=" -DERRMSG=/usr/share/english/errmsg.sys -DMYSQL_EMBEDDED_LIBRARIES=/usr/lib/"
fi

# Install Lua packages
sudo apt-get -y install liblua5.1 liblua5.1-dev

