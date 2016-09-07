echo "nameserver 8.8.8.8" > /etc/resolv.conf 
apt-get update
#apt-get remove -y --force-yes locales language-pack-en-base language-pack-en ubuntu-minimal
apt-get install -y --force-yes wget

apt-get install -y --force-yes gcc g++ make


wget https://cmake.org/files/v3.5/cmake-3.5.2.tar.gz --no-check-certificate
tar xzvf cmake-3.5.2.tar.gz
cd cmake-3.5.2


./bootstrap
make
make install

