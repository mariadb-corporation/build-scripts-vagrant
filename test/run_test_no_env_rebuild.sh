set -x
dir=`pwd`
#. ~/build-scripts/test/get_provider
cd ~/mdbci/$name
#vagrant up
cd ..
. ~/build-scripts/test/set_env_vagrant.sh "$name"
cd $dir
cmake .
#sudo make install
ctest $test_set -VV
~/build-scripts/test/copy_logs.sh
