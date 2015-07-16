#!/bin/bash

set -x

echo "ubuntu_trusty ubuntu_utopic ubuntu_precise ubuntu_vivid deb_wheezy deb_squeeze deb_jessie ubuntu_utopic_ppc64" | grep $box
if [ $? == 0 ] ; then
	ssh $sshopt "sudo apt-get  -y --force-yes remove maxscale"
	ssh $sshopt "sudo dpkg -r mariadb-enterprise-repository.deb"
	ssh $sshopt "wget https://downloads.mariadb.com/enterprise/WY99-BC52/generate/10.0/mariadb-maxscale=1.2/mariadb-enterprise-repository.deb; sudo dpkg -i mariadb-enterprise-repository.deb"
	ssh $sshopt "sudo apt-get update; sudo apt-get install -y --force-yes maxscale"
	res=$?
        ssh $sshopt "sudo apt-get -y --force-yes remove maxscale"
        ssh $sshopt "sudo dpkg -r mariadb-enterprise-repository.deb"
fi

echo "centos7 centos6 centos5 rhel5 rhel6 rhel7 rhel7_ppc64" | grep $box
if [ $? == 0 ] ; then
	ssh $sshopt "sudo yum remove -y maxscale"
	ssh $sshopt "sudo yum remove -y mariadb-enterprise-repository"
	ssh $sshopt "sudo yum install -y https://downloads.mariadb.com/enterprise/WY99-BC52/generate/10.0/mariadb-maxscale=1.2/mariadb-enterprise-repository.rpm"
	ssh $sshopt "sudo yum install -y maxscale"
	res=$?
        ssh $sshopt "sudo yum remove -y maxscale"
        ssh $sshopt "sudo yum remove -y mariadb-enterprise-repository"
fi
echo "suse13 sles11 sles12 sles12_ppc64" | grep $box
if [ $? == 0 ] ; then
	ssh $sshopt "sudo zypper -n --no-gpg-checks remove mariadb-enterprise-repository-suse"
	ssh $sshopt "sudo zypper -n --no-gpg-checks install https://downloads.mariadb.com/enterprise/WY99-BC52/generate/10.0/mariadb-maxscale=1.2/mariadb-enterprise-repository-suse.rpm"
	ssh $sshopt "sudo zypper -n --no-gpg-checks install maxscale"
	res=$?
        ssh $sshopt "sudo zypper -n --no-gpg-checks remove maxscale"
        ssh $sshopt "sudo zypper -n --no-gpg-checks remove mariadb-enterprise-repository-suse"

fi

exit $res

