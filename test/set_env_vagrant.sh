set -x
export config_name="$1"
if [ -z $1 ] ; then
	config_name="test1"
fi
export mdbci_dir="/home/vagrant/mdbci/"

# Number of nodes
export galera_N=4
export repl_N=4
export new_dirs="yes"



# IP of Master/Slave replication setup nodes
export repl_000=`./mdbci show network $config_name/node0 --silent 2> /dev/null`
export repl_001=`./mdbci show network $config_name/node1 --silent 2> /dev/null`
export repl_002=`./mdbci show network $config_name/node2 --silent 2> /dev/null`
export repl_003=`./mdbci show network $config_name/node3 --silent 2> /dev/null`


# IP of Galera cluster nodes
export galera_000=`./mdbci show network $config_name/galera0 --silent 2> /dev/null`
export galera_001=`./mdbci show network $config_name/galera1 --silent 2> /dev/null`
export galera_002=`./mdbci show network $config_name/galera2 --silent 2> /dev/null`
export galera_003=`./mdbci show network $config_name/galera3 --silent 2> /dev/null`


cd $config_name
export repl_private_000=`vagrant ssh node0 -c 'curl http://169.254.169.254/latest/meta-data/local-ipv4' 2> /dev/null`
export repl_private_001=`vagrant ssh node1 -c 'curl http://169.254.169.254/latest/meta-data/local-ipv4' 2> /dev/null`
export repl_private_002=`vagrant ssh node2 -c 'curl http://169.254.169.254/latest/meta-data/local-ipv4' 2> /dev/null`
export repl_private_003=`vagrant ssh node3 -c 'curl http://169.254.169.254/latest/meta-data/local-ipv4' 2> /dev/null`

export galera_private_000=`vagrant ssh galera0 -c 'curl http://169.254.169.254/latest/meta-data/local-ipv4' 2> /dev/null`
export galera_private_001=`vagrant ssh galera1 -c 'curl http://169.254.169.254/latest/meta-data/local-ipv4' 2> /dev/null`
export galera_private_002=`vagrant ssh galera2 -c 'curl http://169.254.169.254/latest/meta-data/local-ipv4' 2> /dev/null`
export galera_private_003=`vagrant ssh galera3 -c 'curl http://169.254.169.254/latest/meta-data/local-ipv4' 2> /dev/null`
cd ..

# kostyl
echo $repl_private_000 | grep "\."
if [ $? != 0 ] ; then
	export repl_private_000=$repl_000
	export repl_private_001=$repl_001
	export repl_private_002=$repl_002
	export repl_private_003=$repl_003

	export galera_private_000=$galera_000
        export galera_private_001=$galera_001
        export galera_private_002=$galera_002
        export galera_private_003=$galera_003
fi

# MariaDB/Mysql port of of Master/Slave replication setup nodes
export repl_port_000=3306
export repl_port_001=3306
export repl_port_002=3306
export repl_port_003=3306

# MariaDB/Mysql Galera cluster nodes
export galera_port_000=3306
export galera_port_001=3306
export galera_port_002=3306
export galera_port_003=3306

export maxdir="/usr/local/mariadb-maxscale"
export maxdir_bin="$maxdir/bin/"

export maxscale_cnf="$maxdir/etc/MaxScale.cnf"
export maxscale_log_dir="$maxdir/log/"

#pushd `dirname $0` > /dev/null
#export test_dir=`pwd`
#popd > /dev/null
export test_dir="$maxdir/system-test/"


export maxscale_binlog_dir="/var/lib/maxscale/Binlog_Service/"


if [ "$new_dirs" == "yes" ] ; then
        export maxdir="/usr/bin/"
        export maxdir_bin="/usr/bin/"
        export maxscale_cnf="/etc/maxscale.cnf"
        export maxscale_log_dir="/var/log/maxscale/"
fi


# IP Of MaxScale machine
export maxscale_IP=`./mdbci show network $config_name/maxscale --silent 2> /dev/null`

# User name and Password for Master/Slave replication setup (should have all PRIVILEGES)
export repl_user="skysql"
export repl_password="skysql"

# User name and Password for Galera setup (should have all PRIVILEGES)
export galera_user="skysql"
export galera_password="skysql"

export maxscale_user="skysql"
export maxscale_password="skysql"

export maxadmin_password="mariadb"

# command to download logs from MaxScale machine
export get_logs_command="$test_dir/get_logs.sh"

# links to ssh keys files for all machines
export repl_sshkey_000=`./mdbci show keyfile $config_name/node0 --silent`
export repl_sshkey_001=`./mdbci show keyfile $config_name/node1 --silent`
export repl_sshkey_002=`./mdbci show keyfile $config_name/node2 --silent`
export repl_sshkey_003=`./mdbci show keyfile $config_name/node3 --silent`

export galera_sshkey_000=`./mdbci show keyfile $config_name/galera0 --silent`
export galera_sshkey_001=`./mdbci show keyfile $config_name/galera1 --silent`
export galera_sshkey_002=`./mdbci show keyfile $config_name/galera2 --silent`
export galera_sshkey_003=`./mdbci show keyfile $config_name/galera3 --silent`

export maxscale_sshkey=`./mdbci show keyfile $config_name/maxscale --silent`

cd $config_name
export access_user=`vagrant ssh maxscale -c 'whoami' 2> /dev/null | tr -cd "[:print:]" `
export access_sudo="sudo "
cd ..

# Sysbench directory (should be sysbench >= 0.5)
export sysbench_dir="/home/turenko/sysbench_deb7/sysbench/"

# command to kill VM (obsolete)
export kill_vm_command="exit 1"
# command to restore VM (obsolete)
export start_vm_command="exit 1"

export repl_kill_vm_command="exit 1"
export repl_start_vm_command="exit 1"
export galera_kill_vm_command="exit 1"
export galera_start_vm_command="exit 1"


export start_db_command="/etc/init.d/mysql start"
export stop_db_command="/etc/init.d/mysql stop"

if [ x"$mysql51_only" == "xyes" ] ; then
        export start_db_command="/etc/init.d/mysqld start"
        export stop_db_command="/etc/init.d/mysqld stop"
fi
