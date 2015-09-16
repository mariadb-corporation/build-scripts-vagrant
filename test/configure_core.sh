#!/bin/bash

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $access_user@$maxscale_IP '$access_sudo service iptables stop'

#ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $access_user@$maxscale_IP "$access_sudo sed -i  \"s/start() {/start() { export DAEMON_COREFILE_LIMIT='unlimited'/\" /etc/init.d/maxscale"

#ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $access_user@$maxscale_IP "echo 2 > /proc/sys/fs/suid_dumpable"

scp -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $HOME/build-scripts/test/add_core_cnf.sh $access_user@$maxscale_IP:/home/$access_user
ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $access_user@$maxscale_IP "$access_sudo /home/$access_user/add_core_cnf.sh"

