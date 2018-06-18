#!/usr/bin/env bash

set -e

if [ $BUILD_TOOLS = false ] && [ $BUILD_TESTING = false ]; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --default-host i686-unknown-linux-gnu
    source ~/.profile

    mkdir rust-g
    cd rust-g
    git init
    git remote add origin https://github.com/tgstation/rust-g
    git fetch --depth 1 origin $RUST_G_VERSION
    git checkout FETCH_HEAD
    cargo build --release

    mkdir -p ~/.byond/bin
    ln -s $PWD/target/release/librust_g.so ~/.byond/bin/rust_g

    mkdir -p ../BSQL/artifacts
    cd ../BSQL
    git init
    git remote add origin https://github.com/tgstation/BSQL
    git fetch --depth 1 origin $BSQL_VERSION
    git checkout FETCH_HEAD

    cd artifacts
    ls /usr/include
    ls /usr/include/mysql
    ls /usr/lib/i386-linux-gnu
    export CXX=g++-7
    export CC=gcc-7
    cmake .. -DMARIA_INCLUDE_DIR=/usr/include -DMARIA_LIBRARY=/usr/lib/i386-linux-gnu/libmariadbclient.so
    make VERBOSE=1
    ln -s src/BSQL/libBSQL.so ~/.byond/bin/
fi
