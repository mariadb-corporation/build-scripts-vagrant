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

cp _CPack_Packages/Linux/DEB/*.deb ../

rm ../CMakeCache.txt
rm CMakeCache.txt
cd ..
cp _build/*.deb .
cp *.deb ..
cp _build/*.gz .


set +x
