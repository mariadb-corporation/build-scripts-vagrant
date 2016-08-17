set -x
dir=`pwd`

. ~/build-scripts/test/configure_log_dir.sh

cd ~/mdbci 

./mdbci snapshot revert --path-to-nodes $name --snapshot-name $snapshot_name

. ~/build-scripts/test/set_env_vagrant.sh "$name"

cd $dir

~/mdbci-repository-config/maxscale-ci.sh $target repo.d $ci_url_suffix
export repo_dir=$dir/repo.d/

if [ -n "$repo_user" ] ; then
        sed -i "s|http://|http://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
        sed -i "s|https://|https://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
fi

cd ~/mdbci

./mdbci sudo --command 'yum remove maxscale -y' $name/maxscale

./mdbci install_product --product maxscale $name/maxscale --repo-dir $repo_dir


cd $dir
cmake .
make
#sudo make install

./check_backend --restart-galera
ctest $test_set -VV

~/build-scripts/test/copy_logs.sh

