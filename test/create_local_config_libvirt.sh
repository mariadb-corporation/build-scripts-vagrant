#!/bin/bash

export version="10.1"
export product="mariadb"
export box="centos_7_libvirt"
export do_not_destroy_vm="yes"
export big="no"
export ci_url="http://max-tst-01.mariadb.com/ci-repository/"
export ci_url_suffix="mariadb-maxscale"
export repo_user=""
export repo_password=""
export logs_dir="$HOME/LOGS"
export vm_memory="512"

. ~/build-scripts/test/create_local_config.sh
