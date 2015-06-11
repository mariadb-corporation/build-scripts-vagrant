#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cd $work_dir

. ~/check_arch.sh

sudo apt-get update
sudo apt-get install -y dpkg-dev

sudo apt-get install -y --force-yes cmake
sudo apt-get install -y --force-yes gcc g++ ncurses-dev bison build-essential libssl-dev libaio-dev perl make libtool 
sudo apt-get install -y --force-yes librabbitmq-dev
sudo apt-get install -y --force-yes libcurl4-openssl-dev
sudo apt-get install -y --force-yes libpcre3-dev

wget --retry-connrefused $mariadbd_link
sudo tar xzvf $mariadbd_file -C /usr/ --strip-components=1

mkdir _build
chmod -R a-w .
chmod u+w _build
cd _build
cmake ..  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/
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
  cmake ../rabbitmq_consumer/  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/
  sudo make package
fi

cp _CPack_Packages/Linux/DEB/*.deb ../
cd ..
chmod -R u+wr .
cp _build/*.deb .
cp *.deb ..
