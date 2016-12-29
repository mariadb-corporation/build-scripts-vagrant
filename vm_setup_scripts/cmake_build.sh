wget https://cmake.org/files/v3.7/cmake-3.7.1.tar.gz --no-check-certificate
tar xzvf cmake-3.7.1.tar.gz
cd cmake-3.7.1

./bootstrap
gmake
make install

