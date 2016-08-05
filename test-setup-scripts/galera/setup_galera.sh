#!/bin/bash

#set -x

N=$galera_N
scr_dir="$HOME/build-scripts/test-setup-scripts"

x=`expr $N - 1`
for i in $(seq 0 $x)
do
	num=`printf "%03d" $i`
	sshkey_var=galera_"$num"_keyfile
	user_var=galera_"$num"_whoami
	IP_var=galera_"$num"_network

	sshkey=${!sshkey_var}
	user=${!user_var}
	IP=${!IP_var}

        ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "sudo mysql_install_db; sudo chown -R mysql:mysql /var/lib/mysql"

	scp -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $scr_dir/galera/* $user@$IP:/home/$user/
        ssh -i $sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$IP "/home/$user/configure.sh"
done


ssh -i  $galera_000_keyfile -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $galera_000_whoami@$galera_000_network "sudo $galera_000_start_db_command --wsrep-cluster-address=gcomm://" &
sleep 10
ssh -i  $galera_000_keyfile -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $galera_000_whoami@$galera_000_network "echo 'CREATE DATABASE IF NOT EXISTS test;' | sudo mysql "

disown
