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

mkdir rabbit
cd rabbit
git clone https://github.com/alanxz/rabbitmq-c.git
cd rabbitmq-c
git checkout v0.7.1
#cmake .  -DCMAKE_C_FLAGS=-fPIC -DBUILD_SHARED_LIBS=N -DCMAKE_INSTALL_PREFIX=/usr
cmake .  -DCMAKE_C_FLAGS=-fPIC -DBUILD_SHARED_LIBS=N -DCMAKE_INSTALL_PREFIX=/usr
sudo make install
cd ../../

wget --retry-connrefused $mariadbd_link
sudo tar xzvf $mariadbd_file -C /usr/ --strip-components=1

mkdir _build
#sudo chmod -R a-w .
#sudo chmod u+w _build
cd _build
#export LD_LIBRARY_PATH=$PWD/log_manager:$PWD/query_classifier:$PWD/server/core
cmake ..  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/
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
  cmake ../rabbitmq_consumer/  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/
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
