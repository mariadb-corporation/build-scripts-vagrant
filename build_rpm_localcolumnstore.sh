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


cd ..
cp _build/*.rpm .
cp _build/*.gz .

