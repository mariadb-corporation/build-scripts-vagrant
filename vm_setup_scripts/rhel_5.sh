yum install -y wget
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -Uvh epel-release-5-4.noarch.rpm
#./cmake_install.sh

yum install -y gcc gcc-c++ make git
#./cmake_build.sh
./cmake_install_olddistros.sh

