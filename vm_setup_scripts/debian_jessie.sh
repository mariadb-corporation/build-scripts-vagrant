echo "nameserver 8.8.8.8" > /etc/resolv.conf 

#apt-get remove -y --force-yes locales language-pack-en-base language-pack-en ubuntu-minimal
#apt-get remove -y --force-yes cmake
apt-get install -y --force-yes wget
./cmake_install.sh

#apt-get install -y --force-yes gcc g++ make

