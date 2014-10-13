#!/bin/bash -e

NASM_VERSION=2.11.02

BUILD_DIR=nasm
SCRIPT_DIR=../engine
: ${PREFIX:=~/.openwebrtc}

export PATH=$PREFIX/bin:$PATH

check_preconditions() {
    $SCRIPT_DIR/test_internet_connection.sh || die "Internet connection is broken."
}

local_clean_source() {
    echo "build-nasm.sh cleaning $BUILD_DIR"
    rm -fr $BUILD_DIR
}

install_sources() {
    mkdir -p $BUILD_DIR
    pushd $BUILD_DIR > /dev/null

    # get nasm
    curl -f -O http://pkgs.fedoraproject.org/repo/pkgs/nasm/nasm-$NASM_VERSION.tar.bz2/3bbc8ed83115b8caf7931f35ec3bc5e0/nasm-$NASM_VERSION.tar.bz2
    tar jxvf nasm-$NASM_VERSION.tar.bz2

    popd > /dev/null
}

build() {
    local arch=$1
    local target_triple=$2

    mkdir -p $PREFIX/bin
    mkdir -p $PREFIX/lib

    (cd $BUILD_DIR && git checkout $target_triple)

    pushd $BUILD_DIR > /dev/null

    export PATH=$PREFIX/bin:$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin
    export DYLD_LIBRARY_PATH=$PREFIX/lib
    export LD_LIBRARY_PATH=$PREFIX/lib
    export JHBUILD_PREFIX=$PREFIX
    export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
    export PKG_CONFIG=$PREFIX/bin/pkg-config
    export PYTHON=`which python2.7`
    export PYTHONPATH=$PREFIX/lib/python2.7/site-packages

    export CFLAGS=$PLATFORM_CFLAGS
    export CPPFLAGS=$PLATFORM_CFLAGS

    # build nasm
    pushd nasm-$NASM_VERSION > /dev/null
    ./configure --prefix=$PREFIX && make && make install || die "$0 -- Could not build nasm."
    popd > /dev/null

    popd > /dev/null
}


# drive
. $SCRIPT_DIR/engine.sh
