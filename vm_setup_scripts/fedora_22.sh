yum install -y wget
#wget http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-1.noarch.rpm
#rpm -ivh epel-release-*.noarch.rpm

yum install -y gcc gcc-c++ make 

wget https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz --no-check-certificate
tar xzvf cmake-3.5.2.tar.gz
cd cmake-3.5.2

./bootstrap
gmake
make install

