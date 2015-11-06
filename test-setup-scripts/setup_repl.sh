#!/bin/bash

#set -x

export scr_dir="$HOME/build-scripts/test-setup-scripts"

x=`expr $repl_N - 1`
for i in $(seq 0 $x)
do
#	echo ${sshkey[$i]}
        num=`printf "%03d" $i`
        sshkey_var="repl_sshkey_$num"
        user_var="repl_access_user_$num"
        IP_var="repl_$num"
	start_cmd_var="repl_start_db_command_$num"
	stop_cmd_var="repl_stop_db_command_$num"

        sshkey=${!sshkey_var}
        user=${!user_var}
        IP=${!IP_var}
	start_cmd=${!start_cmd_var}
	stop_cmd=${!stop_cmd_var}

	ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "sudo  $stop_cmd" &
	sleep 5
	ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP 'sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf'
	ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP 'sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld; sudo service apparmor restart'

	ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "sudo mysql_install_db; sudo chown -R mysql:mysql /var/lib/mysql"
	ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "sudo $start_cmd" &
	sleep 5
        scp -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $scr_dir/create_*_user.sql $user@$IP://home/$user/
        ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "sudo mysql < /home/$user/create_repl_user.sql"
        ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "sudo mysql < /home/$user/create_skysql_user.sql"
done
