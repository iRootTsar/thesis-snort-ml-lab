#!/bin/bash
set -e
echo "=== Building libdaq ==="
cd repos/libdaq
./bootstrap
./configure --prefix=/usr/local/lib/daq_s3
make -j$(nproc)
sudo make install
sudo ldconfig

echo "=== Building libml ==="
cd ../../repos/libml
./configure.sh
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build -j$(nproc)
sudo cmake --install build
sudo ldconfig

echo "=== Building snort3 ==="
cd ../../repos/snort3
rm -rf build
./configure_cmake.sh \
  --prefix=/usr/local/snort \
  --with-daq-includes=/usr/local/lib/daq_s3/include \
  --with-daq-libraries=/usr/local/lib/daq_s3/lib \
  --enable-tcmalloc
cd build
make -j$(nproc)
sudo make install
sudo ldconfig
echo "=== Build completed successfully ==="
