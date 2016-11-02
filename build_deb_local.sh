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
export LD_LIBRARY_PATH=$PWD/log_manager:$PWD/query_classifier
if [ -d ../coverity ] ; then
        tar xzvf ../coverity/coverity_tool.tgz
        export PATH=$PATH:`pwd`/cov-analysis-linux64-7.6.0/bin/
        cov-build --dir cov-int make
        tar czvf maxscale.tgz cov-int
else
        make
fi

export LD_LIBRARY_PATH=$(for i in `find $PWD/ -name '*.so*'`; do echo $(dirname $i); done|sort|uniq|xargs|sed -e 's/[[:space:]]/:/g')
make package
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


cp _CPack_Packages/Linux/DEB/*.deb ../

rm ../CMakeCache.txt
rm CMakeCache.txt
cd ..
cp _build/*.deb .
cp *.deb ..
cp _build/*.gz .

set -x
if [ "$build_experimental" == "yes" ] ; then
        rm -rf _bild
	mkdir _build
	cd _build
	export LD_LIBRARY_PATH=""
	cmake ..  $cmake_flags -DTARGET_COMPONENT=experimental
	export LD_LIBRARY_PATH=$(for i in `find $PWD/ -name '*.so*'`; do echo $(dirname $i); done|sort|uniq|xargs|sed -e 's/[[:space:]]/:/g')
	make package
	cp _CPack_Packages/Linux/DEB/*.deb ../
        cd ..
        cp _build/*.deb .
        cp *.deb ..
	cp _build/*.gz .

        rm -rf _bild
        mkdir _build
        cd _build
        export LD_LIBRARY_PATH=""
        cmake ..  $cmake_flags -DTARGET_COMPONENT=devel
        export LD_LIBRARY_PATH=$(for i in `find $PWD/ -name '*.so*'`; do echo $(dirname $i); done|sort|uniq|xargs|sed -e 's/[[:space:]]/:/g')
        make package
	cp _CPack_Packages/Linux/DEB/*.deb ../
        cd ..
        cp _build/*.deb .
        cp *.deb ..
	cp _build/*.gz .
fi

if [ "$BUILD_RABBITMQ" == "yes" ] ; then
  cmake ../rabbitmq_consumer/  $cmake_flags 
  sudo make package
  res=$?
  if [ $res != 0 ] ; then
        exit $res
  fi
  cp _CPack_Packages/Linux/DEB/*.deb ../
  cd ..
  cp _build/*.deb .
  cp *.deb ..
fi

set +x
