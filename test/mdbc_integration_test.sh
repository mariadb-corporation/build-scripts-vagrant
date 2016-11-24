#!/bin/bash 

export target="release-1.3.0-debug"
export smoke="yes"
#export test_set="15,16"
export name="mdbci-test-$box-$product-$version"
export ci_url="http://maxscale-jenkins.mariadb.com/ci-repository"

oldpwd=`pwd`
echo "Going to switch mdbci branch: [$MDBCI_BRANCH]"
cd ~/mdbci
branch_to_switch=$(echo $MDBCI_BRANCH | awk -F "/" '{print $3}')
echo "Current mdbci branch  "
git fetch -a
git branch | grep '*'
git reset --hard
git clean -fdx
git checkout $branch_to_switch
git pull origin $branch_to_switch
git reset --hard
echo "New mdbci branch  " 
git branch | grep '*'
ln -s ~/conf/aws-config.yml
ln -s ~/conf/maxscale.pem

cd $oldpwd
cd ~/mdbci-boxes/
git pull
cp -r ~/mdbci-boxes/BOXES ~/mdbci/
cp -r ~/mdbci-boxes/KEYS ~/mdbci/

cd $oldpwd
export named_test="check_backend"
~/build-scripts/test/run_test.sh
