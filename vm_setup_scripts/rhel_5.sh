yum install -y wget
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -Uvh epel-release-5-4.noarch.rpm

yum install -y gcc gcc-c++ make

wget https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz --no-check-certificate
tar xzvf cmake-3.5.2.tar.gz
cd cmake-3.5.2

./bootstrap
gmake
make install

