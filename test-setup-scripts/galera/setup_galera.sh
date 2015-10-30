#!/bin/bash

#set -x

N=$galera_N
scr_dir="$HOME/build-scripts/test-setup-scripts"

x=`expr $N - 1`
for i in $(seq 0 $x)
do
	num=`printf "%03d" $i`
	sshkey_var="galera_sshkey_$num"
	user_var="galera_access_user_$num"
	IP_var="galera_$num"

	sshkey=${!sshkey_var}
	user=${!user_var}
	IP=${!IP_var}

        ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "sudo mysql_install_db; sudo chown -R mysql:mysql /var/lib/mysql"

	scp -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $scr_dir/galera/* $user@$IP:/home/$user/
        ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "/home/$user/configure.sh"
done


ssh -i  $galera_sshkey_000 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $galera_access_user_000@$galera_000 "sudo $galera_start_db_command_000 --wsrep-cluster-address=gcomm://" &
sleep 10
ssh -i  $galera_sshkey_000 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $galera_access_user_000@$galera_000 "echo 'CREATE DATABASE IF NOT EXISTS test;' | sudo mysql "

disown
