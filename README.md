# build-scripts-vagrant

Modified build scripts to work with Vagrant-controlled VMs

## Main files

File|Description
----|-----------
prepare_and_build.sh|Create VM for build and execute build, publish resulting repository
build.<provider>.template.json|templates of MDBCI configuration description of build machines|
test-setup-scripts/setup_repl.sh|Prepares repl_XXX machines to be configured into Master/Slave
test-setup-scripts/galera/setup_galera.sh|Prepares galera_XXX machines to be configured into Galera cluster
test-setup-scripts/cnf/|my.cnf files for all backend machines
test/template.<provider>.json|Templates of MDBCI configuration description of test machines|
test/run_test.sh|Creates test environment, build maxscale-system-tests from source and execute tests using ctest
test/set_env_vagrant.sh|set all environment variables for existing test machines using MDBCI to get all values

## prepare_and_build.sh
Following variables have to be defined before executing prepare_and_build.sh

|Variable|Meaning|
|--------|--------|
|$box|name of MDBCI box (see [MDBCI docs](https://github.com/OSLL/mdbci#terminology))|
|$target|name of repository to put result of build|
|$source|BRANCH, TAG or COMMIT|
|$values|name of branch, tag of connit ID|
|$cmake_flags|additional cmake flags|
|$Coverity|if 'yes' build will be done via coverity-build and results will be submitted to scan.coverity.com|
|$do_not_destroy_vm|if 'yes' build VM won't be destroyed after the build. NOTE: do not forget destroy it manually|
|$no_repo|if 'yes' repository won't be built|

Scripts creates MDBCI configuration build_$box-<current data and time>.json, bringing it up (the directory build_$box-<current data and time> is created)

Resulting DEB or RPM first go to ~/pre-repo/$target/$box

NOTE: if ~/pre-repo/$target/$box contains older version they will also go to repostory

Resulting repository goes to ~/repository/$target/mariadb-maxscale/

It is recommeneded to publish ~/repository/ directory on a web server

## run_test.sh
Following variables have to be defined before executing run_test.sh
|Variable|Meaning|
|--------|--------|
|$box|name of MDBCI box for Maxscale machine (see [MDBCI docs](https://github.com/OSLL/mdbci#terminology))|
|$name|unique name of test setup|
|$product|'mariadb' or 'mysql'|
|$version|version of backend DB|
|$target|name of Maxscale repository|
|$ci_url|URL of repostory web site, Maxscale will be installed from $ci_url/$target/mariadb-maxscale/
|$do_not_destroy_vm|if 'yes' build VM won't be destroyed after the build. NOTE: do not forget to destroy it manually|

