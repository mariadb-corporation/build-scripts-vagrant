#!/bin/bash

set -x

IP[0]=$galera_000
IP[1]=$galera_001
IP[2]=$galera_002
IP[3]=$galera_003

N=$galera_N

sshkey[0]=$galera_sshkey_000
sshkey[1]=$galera_sshkey_001
sshkey[2]=$galera_sshkey_002
sshkey[3]=$galera_sshkey_003

vuser[0]=`vagrant ssh galera0 -c 'whoami' 2> /dev/null`
vuser[1]=`vagrant ssh galera1 -c 'whoami' 2> /dev/null`
vuser[2]=`vagrant ssh galera2 -c 'whoami' 2> /dev/null`
vuser[3]=`vagrant ssh galera3 -c 'whoami' 2> /dev/null`

scr_dir="/home/vagrant/build-scripts/test-setup-scripts"

image_type="RPM"

x=`expr $N - 1`
for i in $(seq 0 $x)
do
	scp -r -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $scr_dir/galera/* ${vuser[$i]}@${IP[$i]}:/home/${vuser[$i]}/
	ssh -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo cp -r /home/${vuser[$i]}/* /root/"
	private_ip=`ssh -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} 'curl http://169.254.169.254/latest/meta-data/local-ipv4'`
	if [ -z $private_ip ] ; then
		private_ip=${IP[$i]}
	fi
	ssh -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "export xtrabackup=$xtrabackup ; sudo /root/install-packages.sh ; sudo /root/firewall-setup.sh $maxscale_ip; sudo /root/configure.sh $private_ip node$i"
done

private_ip0=`ssh -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} 'curl http://169.254.169.254/latest/meta-data/local-ipv4'`
if [ -z $private_ip0 ] ; then
        private_ip0=${IP[0]}
fi


scp -r -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $src_dir/galera/* ${vuser[0]}@${IP[0]}:/home/${vuser[$i]}/
ssh -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "sudo /root/firewall-setup.sh $maxscale_ip"

ssh -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "sudo /etc/init.d/mysql start --wsrep-cluster-address=gcomm://" &
sleep 10
ssh -i  ${sshkey[0]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[0]}@${IP[0]} "echo 'CREATE DATABASE IF NOT EXISTS test;' | sudo mysql "

for i in $(seq 1 $x)
do
	ssh -i  ${sshkey[$i]} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${vuser[$i]}@${IP[$i]} "sudo /etc/init.d/mysql start --wsrep-cluster-address=gcomm://$private_ip0" &
	sleep 10
done

disown
