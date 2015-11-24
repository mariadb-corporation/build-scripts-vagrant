set -x
echo $*
export config_name="$1"
if [ -z $1 ] ; then
	config_name="test1"
fi
export mdbci_dir="$HOME/mdbci/"

export curr_dir=`pwd`

# Number of nodes
export galera_N=4
export repl_N=4
export new_dirs="yes"

export maxdir="/usr/local/mariadb-maxscale"
export maxdir_bin="$maxdir/bin/"

export maxscale_cnf="$maxdir/etc/MaxScale.cnf"
export maxscale_log_dir="$maxdir/log/"

export test_dir="$maxdir/system-test/"

export maxscale_binlog_dir="/var/lib/maxscale/Binlog_Service"

if [ "$new_dirs" == "yes" ] ; then
        export maxdir="/usr/bin/"
        export maxdir_bin="/usr/bin/"
        export maxscale_cnf="/etc/maxscale.cnf"
        export maxscale_log_dir="/var/log/maxscale/"
fi

cd $mdbci_dir

# IP Of MaxScale machine
export maxscale_IP=`./mdbci show network $config_name/maxscale --silent 2> /dev/null`
export maxscale_sshkey=`./mdbci show keyfile $config_name/maxscale --silent`

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

for prefix in "repl" "galera"
do
	N_var="$prefix"_N
	Nx=${!N_var}
	N=`expr $Nx - 1`
	for i in $(seq 0 $N)
	do
		num=`printf "%03d" $i`
		if [ $prefix == "repl" ] ; then
			node_n="node"
		else
			node_n="$prefix"
		fi
		ip_var="$prefix"_"$num"
		private_ip_var="$prefix"_private_"$num"

		# get IP
		ip=`./mdbci show network $config_name/$node_n$i --silent 2> /dev/null`
		# get ssh key
   		key=`./mdbci show keyfile $config_name/$node_n$i --silent 2> /dev/null`

		eval 'export "$prefix"_"$num"=$ip'
		eval 'export "$prefix"_sshkey_"$num"=$key'
		eval 'export "$prefix"_port_"$num"=3306'
	
		# trying to get private IP (for AWS)
#		cd $config_name
		private_ip=`./mdbci show private_ip $config_name/$node_n$i --silent 2> /dev/null`

		eval 'export "$prefix"_private_"$num"="$private_ip"'

		au=`./mdbci ssh --command 'whoami' $config_name/$node_n$i --silent 2> /dev/null | tr -cd "[:print:]" `
		eval 'export "$prefix"_access_user_"$num"="$au"'
		eval 'export "$prefix"_access_sudo_"$num"=sudo'

		server_num=`expr $i + 1`
		start_cmd_var="$prefix"_start_db_command_"$num"
		stop_cmd_var="$prefix"_stop_db_command_"$num"
		mysql_exe=`./mdbci ssh --command 'ls /etc/init.d/mysql* 2> /dev/null | tr -cd "[:print:]"' $config_name/$node_n$i  --silent 2> /dev/null`
		echo $mysql_exe | grep -i "mysql"
		if [ $? != 0 ] ; then
			./mdbci ssh --command 'echo \"/usr/sbin/mysqld \$* 2> stderr.log > stdout.log &\" > mysql_start.sh; echo \"sleep 20\" >> mysql_start.sh; echo \"disown\" >> mysql_start.sh; chmod a+x mysql_start.sh' $config_name/$node_n$i  --silent
                        eval 'export $start_cmd_var="/home/$au/mysql_start.sh "'
                        eval 'export $stop_cmd_var="/usr/bin/killall mysqld "'
		else
			eval 'export $start_cmd_var="$mysql_exe start "'
			eval 'export $stop_cmd_var="$mysql_exe stop "'
		fi

		eval 'export "$prefix"_start_vm_command_"$num"="\"cd $mdbci_dir/$config_name;vagrant up $node_n$i --provider=$provider; cd $curr_dir\""'
		eval 'export "$prefix"_kill_vm_command_"$num"="\"cd $mdbci_dir/$config_name;vagrant halt $node_n$i --provider=$provider; cd $curr_dir\""'
#		cd ..
	done
done

cd $mdbci_dir
export maxscale_access_user=`./mdbci ssh --command 'whoami' $config_name/maxscale --silent 2> /dev/null | tr -cd "[:print:]" `
export maxscale_access_sudo="sudo "
export maxscale_hostname=`./mdbci ssh --command 'hostname' $config_name/maxscale --silent 2> /dev/null | tr -cd "[:print:]" `
#cd ..

# Sysbench directory (should be sysbench >= 0.5)
export sysbench_dir="$HOME/sysbench_deb7/sysbench/"

export ssl=true
cd $curr_dir
