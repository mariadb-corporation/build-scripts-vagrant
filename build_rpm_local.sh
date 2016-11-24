#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cd $work_dir

. ~/check_arch.sh

mkdir _build
#sudo chmod -R a-w .
#sudo chmod u+w _build
cd _build
cmake ..  $cmake_flags 
if [ -d ../coverity ] ; then
  tar xzvf ../coverity/cov-analysis-linux64-7.7.0.4.tar.gz
  export PATH=$PATH:`pwd`/cov-analysis-linux64-7.7.0.4/bin/
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
sudo make package
res=$?
if [ $res != 0 ] ; then
	echo "Make package failed"
	exit $res
fi

sudo rm ../CMakeCache.txt
sudo rm CMakeCache.txt

echo "Building tarball..."
cmake .. $cmake_flags -DTARBALL=Y
sudo make package

# manual tarball build
#
#cmake ..\
#      -DCMAKE_INSTALL_PREFIX=/usr/local/maxscale\
#
#      -DMAXSCALE_VARDIR=/usr/local/masxcale/var\
#
#      -DMAXSCALE_CONFDIR=/usr/local/maxscale/etc\
#make
#sudo make install
#w_dir=$PWD
#cd /usr/local
#sudo mv maxscale maxscale-2.0.0
#sudo tar -czvf maxscale-2.0.0.tar.gz maxscale-2.0.0
#cd $w_dir

cd ..
cp _build/*.rpm .
cp _build/*.gz .
#cp /usr/local/maxscale-2.0.0.tar.gz maxscale-2.0.0-$platform.$platform_version.tar.gz

#sudo rm ../CMakeCache.txt
#sudo rm CMakeCache.txt
if [ "$build_experimental" == "yes" ] ; then
        sudo rm -rf _build
        mkdir _build
        cd _build
        cmake ..  $cmake_flags -DTARGET_COMPONENT=experimental
        sudo make package
        cd ..
        cp _build/*.rpm .
	cp _build/*.gz .

        sudo rm -rf _build
        mkdir _build
        cd _build
        cmake ..  $cmake_flags -DTARGET_COMPONENT=devel
        sudo make package
        cd ..
        cp _build/*.rpm .
	cp _build/*.gz .
fi

if [ "$BUILD_RABBITMQ" == "yes" ] ; then
  cmake ../rabbitmq_consumer/  $cmake_flags 
  sudo make package
  res=$?
  if [ $res != 0 ] ; then
        exit $res
  fi
  cd ..
  cp _build/*.rpm .
  cp _build/*.gz .
fi
