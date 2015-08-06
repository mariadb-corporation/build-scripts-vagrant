#!/bin/bash

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP 'service iptables stop'

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "sed -i  \"s/start() {/start() { export DAEMON_COREFILE_LIMIT='unlimited'/\" /etc/init.d/maxscale"

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "echo 2 > /proc/sys/fs/suid_dumpable"

scp -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $HOME/build-scripts/test/add_core_cnf.sh root@$maxscale_IP:/root/
ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$maxscale_IP "/root/add_core_cnf.sh"

