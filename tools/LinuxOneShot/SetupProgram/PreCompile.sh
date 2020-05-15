#!/bin/bash

set -e
set -x

#find out what we have (+e is important for this)
set +e
has_git="$(command - v git)"
has_d2u="$(command - v dos2unix)"
has_cargo="$(command -v ~/.cargo/bin/cargo)"
has_sudo="$(command -v sudo)"
has_cmake="$(command -v cmake)"
has_gpp="$(command -v g++-6)"
has_grep="$(command -v grep)"
set -e

# install cargo if needful
if ! [ -x "$has_cargo" ]; then
	echo "Installing rust..."
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-host i686-unknown-linux-gnu
	. ~/.profile
fi

# apt packages
if ! { [ -x "$has_git" ] && [ -x "$has_cmake" ] && [ -x "$has_gpp" ] && [ -x "$has_grep" ] && [ -x "$has_d2u" ] && [ -f "/usr/lib/i386-linux-gnu/libmariadb.so.2" ] && [ -f "/usr/lib/i386-linux-gnu/libssl.so" ] && [ -d "/usr/share/doc/g++-6-multilib" ] && [ -f "/usr/bin/mysql" ] && [ -d "/usr/include/mysql" ]; }; then
	echo "Installing apt dependencies..."
	if ! [ -x "$has_sudo" ]; then
		dpkg --add-architecture i386
		apt-get update
		apt-get install -y git cmake libmariadb-dev:i386 libssl-dev:i386 grep g++-6 g++-6-multilib mysql-client dos2unix
		ln -s /usr/include/mariadb /usr/include/mysql
		rm -rf /var/lib/apt/lists/*
	else
		sudo dpkg --add-architecture i386
		sudo apt-get update
		sudo apt-get install -y git cmake libmariadb-dev:i386 libssl-dev:i386 grep g++-6 g++-6-multilib mysql-client dos2unix
		sudo ln -s /usr/include/mariadb /usr/include/mysql
		sudo rm -rf /var/lib/apt/lists/*
	fi
fi

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
file dependencies.sh
dos2unix dependencies.sh
chmod +x dependencies.sh
. dependencies.sh
cd "$original_dir"

#update rust-g
if [ ! -d "rust-g" ]; then
	echo "Cloning rust-g..."
	git clone https://github.com/tgstation/rust-g
else
	echo "Fetching rust-g..."
	cd rust-g
	git fetch
	cd ..
fi

#update BSQL
if [ ! -d "BSQL" ]; then
	echo "Cloning BSQL..."
	git clone https://github.com/tgstation/BSQL
else
	echo "Fetching BSQL..."
	cd BSQL
	git fetch
	cd ..
fi

echo "Deploying rust-g..."
cd rust-g
git checkout "$RUST_G_VERSION"
~/.cargo/bin/cargo build --release
mv target/release/librust_g.so "$1/rust_g"
cd ..

echo "Deploying BSQL..."
cd BSQL
git checkout "$BSQL_VERSION"
mkdir -p mysql
mkdir -p artifacts
cd artifacts
cmake .. -DCMAKE_CXX_COMPILER=g++-6 -DMARIA_LIBRARY=/usr/lib/i386-linux-gnu/libmariadb.so.2
make
mv src/BSQL/libBSQL.so "$1/"

if [ ! -d "$1/../../../Configuration/GameStaticFiles/config" ]; then
	echo "Creating initial config..."
	cp -r "$1/config" "$1/../../../Configuration/GameStaticFiles/config"
	echo -e "SQL_ENABLED\nADDRESS mariadb\nPORT 3306\nFEEDBACK_DATABASE ss13\nFEEDBACK_LOGIN root\nFEEDBACK_PASSWORD YouDefinitelyShouldNOTChangeThis\nASYNC_QUERY_TIMEOUT 10\nBLOCKING_QUERY_TIMEOUT 5\nBSQL_THREAD_LIMIT 50" > "$1/../../../Configuration/GameStaticFiles/config/dbconfig.txt"
fi

DATABASE_EXISTS="$(mysqlshow --user=root --password=YouDefinitelyShouldNOTChangeThis ss13_db| grep -v Wildcard | grep -o ss13_db)"
if [ "$DATABASE_EXISTS" != "ss13_db" ]; then
	echo "Creating initial SS13 database..."
    mysql -u root -p YouDefinitelyShouldNOTChangeThis -h mariadb -P 3306 -e 'CREATE DATABASE ss13_db;'
    mysql -u root -p YouDefinitelyShouldNOTChangeThis -h mariadb -P 3306 -e ss13_db < "$1/SQL/tgstation_schema.sql"
fi
