#!/bin/bash

sed "s/###target###/$target/" /home/ec2-user/test-scripts/maxscale.repo.template > maxscale.repo
sed -i "s/###image###/$image/" maxscale.repo
sed "s/###target###/$target/" /home/ec2-user/test-scripts/apt_maxscale/$image/maxscale.list > maxscale.list

scp -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no maxscale.repo root@$maxscale_IP:/etc/yum.repos.d/
scp -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no maxscale.repo root@$maxscale_IP:/etc/zypp/repos.d/
scp -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no maxscale.list root@$maxscale_IP:/etc/apt/sources.list.d/

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP 'service iptables stop'

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "yum -y install maxscale"
ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "apt-get update; apt-get install -y maxscale"
ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "zypper -n install maxscale"

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "sed -i  \"s/start() {/start() { export DAEMON_COREFILE_LIMIT='unlimited'/\" /etc/init.d/maxscale"

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "echo 2 > /proc/sys/fs/suid_dumpable"

scp -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $HOME/build-scripts/test/add_core_cnf.sh root@$maxscale_IP:/root/
ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "/root/add_core_cnf.sh"

