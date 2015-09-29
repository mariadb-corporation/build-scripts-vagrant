#!/bin/bash

ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $maxscale_access_user@$maxscale_IP '$maxscale_access_sudo service iptables stop'

scp -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $HOME/build-scripts/test/add_core_cnf.sh $maxscale_access_user@$maxscale_IP:/home/$maxscale_access_user
ssh -i $maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $maxscale_access_user@$maxscale_IP "$maxscale_access_sudo /home/$maxscale_access_user/add_core_cnf.sh"

