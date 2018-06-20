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

    if [ -f "$HOME/MariaDB/libmariadb.so.2" ] && [ -f "$HOME/MariaDB/libmariadb.so" ] && [ -d "$HOME/MariaDB/include" ];
    then
        echo "Using cached MariaDB library."
    else
        echo "Setting up MariaDB."
        rm -rf "$HOME/MariaDB"
        mkdir -p "$HOME/MariaDB"
        wget http://mirrors.kernel.org/ubuntu/pool/universe/m/mariadb-client-lgpl/libmariadb2_2.0.0-1_i386.deb
        dpkg -x libmariadb2_2.0.0-1_i386.deb /tmp/extract
        rm libmariadb2_2.0.0-1_i386.deb
        mv /tmp/extract/usr/lib/i386-linux-gnu/libmariadb.so.2 $HOME/MariaDB/
        ln -s $HOME/MariaDB/libmariadb.so.2 $HOME/MariaDB/libmariadb.so
        rm -rf /tmp/extract

        wget http://mirrors.kernel.org/ubuntu/pool/universe/m/mariadb-connector-c/libmariadb-dev_2.3.3-1_i386.deb
        dpkg -x libmariadb-dev_2.3.3-1_i386.deb /tmp/extract
        rm libmariadb-dev_2.3.3-1_i386.deb
        mv /tmp/extract/usr/include $HOME/MariaDB/
    fi

    cd artifacts
    export CXX=g++-7
    ls /usr/include
    cmake .. -DMARIA_INCLUDE_DIR=$HOME/MariaDB/include
    make
    mv src/BSQL/libBSQL.so ../../
    ldd ../../libBSQL.so
fi
