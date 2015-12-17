# How to run test

## Prerequirements 

Installed MDBCI (with dependencies, see [MDBCI doc](https://github.com/OSLL/mdbci#mariadb-continuous-integration-infrastructure-mdbci)), [mdbci-repository-config]
(https://github.com/mariadb-corporation/mdbci-repository-config#mdbci-repository-config)

mdbci-repository-config should be in ~/mdbci-repository-config/

build-scripts - in ~/build-scripts/

mdbci - in ~/mdbci/

## Creating test configuration and running tests example

> export name="my-centos7-release-1.3.0-test"

> export box="centos7"

> export product="mariadb"

> export version="5.5"

> export target="release-1.3.0"

> export ci_url="http://max-tst-01.mariadb.com/ci-repository/"

> export do_not_destroy_vm="yes"

> export test_set="1,10,,20,30,95"

> ~/build-scripts/test/run_test.sh

~/build-scripts/

## Running tests with existing test configuration

> cd ~/mdbci

> export name="running_conf_name"

> . ../build-scripts/test/set_env_vagrant.sh $name

> set +x

> cd $name

> git clone https://github.com/mariadb-corporation/maxscale-system-test.git

> cd maxscale-system-test

> cmake .

> make

> ./test_executable_name

or use ctest to run several tests
