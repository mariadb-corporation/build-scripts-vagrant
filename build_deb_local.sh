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

mkdir rabbit
cd rabbit
git clone https://github.com/alanxz/rabbitmq-c.git
cd rabbitmq-c
git checkout v0.7.1
#cmake .  -DCMAKE_C_FLAGS=-fPIC -DBUILD_SHARED_LIBS=N -DCMAKE_INSTALL_PREFIX=/usr
cmake .  -DCMAKE_C_FLAGS=-fPIC -DBUILD_SHARED_LIBS=N -DCMAKE_INSTALL_PREFIX=/usr
sudo make install
cd ../../
# Check for Avro client library
if [[ "$cmake_flags" =~ .*"BUILD_AVRO".* ]]
then
     # SQLite3
     sudo apt-get install -y --force-yes libsqlite3-dev sqlite3

     # Jansson
     git clone https://github.com/akheron/jansson.git
     mkdir -p jansson/build
     pushd jansson/build
     cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_FLAGS=-fPIC -DJANSSON_INSTALL_LIB_DIR=/usr/lib64
     make
     sudo make install
     popd
 
     # Avro C API
     wget http://mirror.netinch.com/pub/apache/avro/avro-1.8.0/c/avro-c-1.8.0.tar.gz
     tar -axf avro-c-1.8.0.tar.gz
     mkdir avro-c-1.8.0/build
     pushd avro-c-1.8.0/build
     cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_FLAGS=-fPIC -DCMAKE_CXX_FLAGS=-fPIC
     make
     sudo make install
     popd
fi

wget --retry-connrefused $mariadbd_link
sudo tar xzvf $mariadbd_file -C /usr/ --strip-components=1

mkdir _build
#sudo chmod -R a-w .
#sudo chmod u+w _build
cd _build
#export LD_LIBRARY_PATH=$PWD/log_manager:$PWD/query_classifier:$PWD/server/core
cmake ..  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DMYSQL_EMBEDDED_LIBRARIES=/usr/lib/
#cmake ..  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DMYSQL_EMBEDDED_INCLUDE_DIR
export LD_LIBRARY_PATH=$PWD/log_manager:$PWD/query_classifier
if [ -d ../coverity ] ; then
        tar xzvf ../coverity/coverity_tool.tgz
        export PATH=$PATH:`pwd`/cov-analysis-linux64-7.6.0/bin/
        cov-build --dir cov-int make
        tar czvf maxscale.tgz cov-int
else
        make
fi
if [ $remove_strip == "yes" ] ; then
        sudo rm -rf /usr/bin/strip
        sudo touch /usr/bin/strip
        sudo chmod a+x /usr/bin/strip
fi 
#sudo make install
export LD_LIBRARY_PATH=$(for i in `find $PWD/ -name '*.so*'`; do echo $(dirname $i); done|sort|uniq|xargs|sed -e 's/[[:space:]]/:/g')
make package
res=$?
if [ $res != 0 ] ; then
        exit $res
fi

rm ../CMakeCache.txt
rm CMakeCache.txt

if [ "$BUILD_RABBITMQ" == "yes" ] ; then
  cmake ../rabbitmq_consumer/  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DMYSQL_EMBEDDED_LIBRARIES=/usr/lib/
  sudo make package
  res=$?
  if [ $res != 0 ] ; then
        exit $res
  fi
fi

cp _CPack_Packages/Linux/DEB/*.deb ../
cd ..
#chmod -R u+wr .
cp _build/*.deb .
cp *.deb ..
