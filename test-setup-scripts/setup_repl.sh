#!/bin/bash

set -x

IP[0]=$repl_000
IP[1]=$repl_001
IP[2]=$repl_002
IP[3]=$repl_003

IP_private[0]=$repl_private_000
IP_private[1]=$repl_private_001
IP_private[2]=$repl_private_002
IP_private[3]=$repl_private_003

sshkey[0]=$repl_sshkey_000
sshkey[1]=$repl_sshkey_001
sshkey[2]=$repl_sshkey_002
sshkey[3]=$repl_sshkey_003

vuser[0]=`vagrant ssh node0 -c 'whoami' 2> /dev/null`
vuser[1]=`vagrant ssh node1 -c 'whoami' 2> /dev/null`
vuser[2]=`vagrant ssh node2 -c 'whoami' 2> /dev/null`
vuser[3]=`vagrant ssh node3 -c 'whoami' 2> /dev/null`

repl_start_db_command[0]=$repl_start_db_command_000
repl_start_db_command[1]=$repl_start_db_command_001
repl_start_db_command[2]=$repl_start_db_command_002
repl_start_db_command[3]=$repl_start_db_command_003

galera_start_db_command[0]=$galera_start_db_command_000
galera_start_db_command[1]=$galera_start_db_command_001
galera_start_db_command[2]=$galera_start_db_command_002
galera_start_db_command[3]=$galera_start_db_command_003

repl_stop_db_command[0]=$repl_stop_db_command_000
repl_stop_db_command[1]=$repl_stop_db_command_001
repl_stop_db_command[2]=$repl_stop_db_command_002
repl_stop_db_command[3]=$repl_stop_db_command_003

galera_stop_db_command[0]=$galera_stop_db_command_000
galera_stop_db_command[1]=$galera_stop_db_command_001
galera_stop_db_command[2]=$galera_stop_db_command_002
galera_stop_db_command[3]=$galera_stop_db_command_003


export scr_dir="/home/vagrant/build-scripts/test-setup-scripts"

echo ${sshkey[0]}

x=`expr $repl_N - 1`
for i in $(seq 0 $x)
do
	echo ${sshkey[$i]}
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo  ${repl_stop_db_command[$i]}" &
	sleep 5
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld; sudo service apparmor restart'

        dir="/etc/my.cnf.d"
	server_id=`expr $i + 1`
	sed "s/###SERVER_ID###/$server_id/"  $scr_dir/server.cnf.template >  ./server.cnf

	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo sudo sh -c 'echo !includedir /etc/my.cnf.d >> /etc/my.cnf'"
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo mkdir -p $dir"
	scp -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ./server.cnf ${vuser[$i]}@${IP[$i]}:./
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo cp ./server.cnf $dir/"

	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp -m tcp --dport 3306 -j ACCEPT'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp --dport 3306 -j ACCEPT -m state --state NEW'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp -m tcp --dport 4006 -j ACCEPT'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp --dport 4006 -j ACCEPT -m state --state NEW'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp -m tcp --dport 4008 -j ACCEPT'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp --dport 4009 -j ACCEPT -m state --state NEW'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp -m tcp --dport 4008 -j ACCEPT'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp --dport 4008 -j ACCEPT -m state --state NEW'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp -m tcp --dport 4442 -j ACCEPT'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp --dport 4442 -j ACCEPT -m state --state NEW'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp -m tcp --dport 6444 -j ACCEPT'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp --dport 6444 -j ACCEPT -m state --state NEW'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp -m tcp --dport 5306 -j ACCEPT'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables -I INPUT -p tcp --dport 5306 -j ACCEPT -m state --state NEW'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo /etc/init.d/iptables save'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo iptables save'
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo /sbin/service iptables save'

	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo mysql_install_db; sudo chown -R mysql:mysql /var/lib/mysql"
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo ${repl_start_db_command[$i]}" &
	sleep 5
#	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'sudo systemctl start mariadb.service'
done

scp -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $scr_dir/create_*_user.sql ${vuser[0]}@${IP[0]}:/home/${vuser[0]}
ssh -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "cat  /home/${vuser[0]}/create_repl_user.sql"
ssh -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "sudo mysql < /home/${vuser[0]}/create_repl_user.sql"
ssh -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "cat  /home/${vuser[0]}/create_repl_user.sql"
for i in $(seq 1 $x)
do
	scp -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $scr_dir/create_*_user.sql ${vuser[$i]}@${IP[$i]}://home/${vuser[i]}/
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo mysql < /home/${vuser[i]}/create_repl_user.sql"
	log_file=`ssh -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} 'echo "SHOW MASTER STATUS\G;" | sudo mysql ' | grep "File:" | sed "s/File://" | sed "s/ //g"`
	log_pos=`ssh -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} 'echo "SHOW MASTER STATUS\G;" | sudo mysql ' | grep "Position:" | sed "s/Position://" | sed "s/ //g"`

	sed "s/###IP###/${IP_private[0]}/" $scr_dir/setup_slave.sql.template | sed "s/###LOG_FILE###/$log_file/" | sed "s/###LOG_POS###/$log_pos/" > $scr_dir/setup_slave.sql
        scp -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $scr_dir/setup_slave.sql ${vuser[$i]}@${IP[$i]}://home/${vuser[i]}/

	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo mysql < /home/${vuser[i]}/setup_slave.sql"
	ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "cat  /home/${vuser[i]}//setup_slave.sql"
done

ssh -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "sudo yum install -y psmisc ; sudo apt-get install -y --force-yes psmisc; sudo zypper -n install psmisc"

ssh -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "sudo mysql < /home/${vuser[0]}/create_skysql_user.sql"

ssh -i ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "cat  /home/${vuser[0]}/create_skysql_user.sql"

