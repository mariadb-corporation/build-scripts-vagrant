#!/bin/bash

dir=`pwd`


export MDBCI_VM_PATH=$HOME/vms; mkdir -p $MDBCI_VM_PATH
export target=`echo $target | sed "s/?//g"`
export name=`echo $name | sed "s/?//g"`
export repo_dir=$dir/repo.d/
export do_not_destroy_vm="yes"

~/mdbci/repository-config/generate_all.sh repo.d
if [ "$debug_mode" != "debug" ] ; then
        ~/mdbci/repository-config/maxscale-ci.sh $target repo.d $ci_url_suffix
fi

export repo_dir=$dir/repo.d/

if [ -n "$repo_user" ] ; then
        sed -i "s|http://|http://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
        sed -i "s|https://|https://$repo_user:$repo_password@|" $repo_dir/maxscale/*.json
fi

cp "$HOME/build-scripts/test/$template.json"  "$MDBCI_VM_PATH/$name.json"

$HOME/mdbci/mdbci --override --template  $MDBCI_VM_PATH/$name.json --repo-dir $repo_dir generate $name


while [ -f ~/vagrant_lock ]
do
        echo "vagrant is locked, waiting ..."
        sleep 5
done
touch ~/vagrant_lock
echo $JOB_NAME-$BUILD_NUMBER >> ~/vagrant_lock

$HOME/mdbci/mdbci up $name --attempts 3

cp ~/build-scripts/team_keys .
$HOME/mdbci/mdbci  public_keys --key team_keys $name

