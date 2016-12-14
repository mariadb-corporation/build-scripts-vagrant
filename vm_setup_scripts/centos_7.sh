yum install -y gcc gcc-c++ make

tar xzvf $cmake_tarball
cp -rt /usr ${cmake_tarball%tar.gz}/*
