#!/usr/bin/env bash
# need a bit of special configuration for cross-compiling cctools-port ...
# https://github.com/tpoechtrager/cctools-port/pull/137#issuecomment-1710484561

# modify as desired
TARGET_ARCH="aarch64-linux-gnu"

GCC_VERSION=$(gcc -dumpversion)

SYSROOT_PATH="$(which gcc)/../$TARGET_ARCH"

WDIR="$HOME/work"
CC="$WDIR/llvm-project/llvm-project/build-host/bin/clang"
CXX="$WDIR/llvm-project/llvm-project/build-host/bin/clang++"

FLAGS="-Qunused-arguments"
FLAGS+=" --target=$TARGET_ARCH"
FLAGS+=" --sysroot $SYSROOT_PATH/sysroot"
FLAGS+=" -isystem $SYSROOT_PATH/include/c++/$GCC_VERSION/"
FLAGS+=" -isystem $SYSROOT_PATH/include/c++/$GCC_VERSION/bits"
FLAGS+=" -isystem $SYSROOT_PATH/include/c++/$GCC_VERSION/debug"
FLAGS+=" -isystem $SYSROOT_PATH/include/c++/$GCC_VERSION/$TARGET_ARCH"

FLAGS+=" -Wl,--sysroot=$SYSROOT_PATH/sysroot -L$SYSROOT_PATH/sysroot/usr/lib"
FLAGS+=" -L $SYSROOT_PATH/../lib/gcc/$TARGET_ARCH/$GCC_VERSION"

exec "$COMPILER" $FLAGS "$@"
