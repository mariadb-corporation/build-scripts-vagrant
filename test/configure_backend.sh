. ~/build-scripts/test/set_env_vagrant.sh $name
cd $name
~/build-scripts/test-setup-scripts/setup_repl.sh
~/build-scripts/test-setup-scripts/galera/setup_galera.sh

~/build-scripts/test/configure_core.sh

cd $dir
rm ~/vagrant_lock

