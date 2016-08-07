set -x
dir=`pwd`

cd ~/mdbci 

./mdbci snapshot revert --path-to-nodes $name --snapshot-name $snapshot_name

. ~/build-scripts/test/set_env_vagrant.sh "$name"

cd $dir
echo Target is $target
~/mdbci-repository-config/maxscale-ci.sh $target repo.d
export repo_dir=$dir/repo.d/

if [ -n "$repo_user" ] ; then
        sed -i "s|http://|http://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
        sed -i "s|https://|https://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
fi

cd ~/mdbci

./mdbci sudo --command 'yum remove maxscale -y' $name/maxscale

./mdbci setup_repo --product maxscale $name/maxscale --repo-dir $repo_dir
./mdbci install_product --product maxscale $name/maxscale --repo-dir $repo_dir


cd $dir
cmake .
make
#sudo make install

./check_backend --restart-galera
ctest $test_set -VV
