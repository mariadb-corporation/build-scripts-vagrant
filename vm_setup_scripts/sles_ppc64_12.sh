zypper -n install wget
#wget http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-1.noarch.rpm
#rpm -ivh epel-release-*.noarch.rpm

zypper -n install gcc gcc-c++ make
./cmake_build.sh

