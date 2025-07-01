#!/bin/bash

# Exit on any error
set -e

# Step 1: Set install location
export MY_INSTALL_DIR="$HOME/.local"
mkdir -p "$MY_INSTALL_DIR"

# Step 2: Add to PATH temporarily
export PATH="$MY_INSTALL_DIR/bin:$PATH"

# Step 3: Clone gRPC v1.56.2 with submodules
git clone -b v1.56.2 https://github.com/grpc/grpc grpc
cd grpc
git submodule update --init

# Step 4: Build and install
mkdir -p cmake/build
cd cmake/build

cmake -DgRPC_INSTALL=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DgRPC_BUILD_TESTS=OFF \
      -DgRPC_PROTOBUF_PROVIDER=module \
      -DCMAKE_INSTALL_PREFIX="$MY_INSTALL_DIR" \
      ../..

make -j$(nproc)
make install

echo ""
echo "Intalled gRPC"
echo "Now Installing luci wheelchair nodes"

cd
mkdir -p ~/ros2_ws/src/luci_ros2/src
cd ~/ros2_ws/src/luci_ros2/src
git clone https://github.com/lucimobility/luci-ros2-grpc.git
git clone https://github.com/lucimobility/luci-ros2-msgs.git
git clone https://github.com/lucimobility/luci-ros2-transforms.git
git clone https://github.com/lucimobility/luci-ros2-keyboard-teleop.git

echo "Now to fix the error with grpc" 

cd luci-ros2-grpc/luci_grpc_interface/client/include/client

HEADER_FILE="common_types.h"
if [ ! -f "$HEADER_FILE" ]; then
  echo "$HEADER_FILE not found in current directory!"
  exit 1
fi

if grep -q "#include <cstdint>" "$HEADER_FILE"; then
  echo "<cstdint> already included in $HEADER_FILE"
else
  sed -i '/#include/s|^|#include <cstdint>\n|' "$HEADER_FILE"
  echo "Added '#include <cstdint>' to $HEADER_FILE"
fi

echo "Finished with the install!" 
