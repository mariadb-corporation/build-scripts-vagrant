#!/bin/bash

set -x

IP[0]=$galera_000
IP[1]=$galera_001
IP[2]=$galera_002
IP[3]=$galera_003

private_IP[0]=$galera_private_000
private_IP[1]=$galera_private_001
private_IP[2]=$galera_private_002
private_IP[3]=$galera_private_003

N=$galera_N

sshkey[0]=$galera_sshkey_000
sshkey[1]=$galera_sshkey_001
sshkey[2]=$galera_sshkey_002
sshkey[3]=$galera_sshkey_003

dir1=`pwd`
cd ..
vuser[0]=`./mdbci ssh --command 'whoami' $name/galera0 --silent 2> /dev/null`
vuser[1]=`./mdbci ssh --command 'whoami' $name/galera1 --silent 2> /dev/null`
vuser[2]=`./mdbci ssh --command 'whoami' $name/galera2 --silent 2> /dev/null`
vuser[3]=`./mdbci ssh --command 'whoami' $name/galera3 --silent 2> /dev/null`
cd $dir1

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


scr_dir="/home/vagrant/build-scripts/test-setup-scripts"

image_type="RPM"

x=`expr $N - 1`
for i in $(seq 0 $x)
do
	scp -r -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $scr_dir/galera/* ${vuser[$i]}@${IP[$i]}:/home/${vuser[$i]}/
	ssh -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo cp -r /home/${vuser[$i]}/* /root/"
#	ssh -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "export xtrabackup=$xtrabackup ; sudo /root/install-packages.sh ; sudo /root/firewall-setup.sh $maxscale_ip; sudo /root/configure.sh ${private_IP[$i]} node$i"
        ssh -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "export xtrabackup=$xtrabackup ; sudo /root/install-packages.sh ; sudo /root/configure.sh ${private_IP[$i]} node$i"

        ssh -i ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo mysql_install_db; sudo chown -R mysql:mysql /var/lib/mysql"
done

scp -r -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $src_dir/galera/* ${vuser[0]}@${IP[0]}:/home/${vuser[$i]}/
#ssh -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "sudo /root/firewall-setup.sh $maxscale_ip"

ssh -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "sudo ${galera_start_db_command[0]} --wsrep-cluster-address=gcomm://" &
sleep 10
ssh -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "echo 'CREATE DATABASE IF NOT EXISTS test;' | sudo mysql "

for i in $(seq 1 $x)
do
	ssh -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo ${galera_start_db_command[$i]} --wsrep-cluster-address=gcomm://${private_IP[0]}" &
	sleep 10
done

disown
