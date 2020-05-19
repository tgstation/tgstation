#!/bin/bash

set -e
set -x

#load dep exports
#need to switch to game dir for Dockerfile weirdness
original_dir=$PWD
cd "$1"
. dependencies.sh
cd "$original_dir"

#find out what we have (+e is important for this)
set +e
has_git="$(command -v git)"
has_cargo="$(command -v ~/.cargo/bin/cargo)"
has_sudo="$(command -v sudo)"
has_cmake="$(command -v cmake)"
has_gpp="$(command -v g++-6)"
has_grep="$(command -v grep)"
DATABASE_EXISTS="$(mysqlshow --host mariadb --port 3306 --user=root --password=$MYSQL_ROOT_PASSWORD ss13_db| grep -v Wildcard | grep -o ss13_db)"
set -e

# install cargo if needful
if ! [ -x "$has_cargo" ]; then
	echo "Installing rust..."
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-host i686-unknown-linux-gnu
	. ~/.profile
fi

# apt packages
if ! { [ -x "$has_git" ] && [ -x "$has_cmake" ] && [ -x "$has_gpp" ] && [ -x "$has_grep" ] && [ -f "/usr/lib/i386-linux-gnu/libmariadb.so.3" ] && [ -f "/usr/lib/i386-linux-gnu/libssl.so" ] && [ -d "/usr/share/doc/g++-6-multilib" ] && [ -f "/usr/bin/mysql" ] && [ -d "/usr/include/mysql" ]; }; then
	echo "Installing apt dependencies..."
	if ! [ -x "$has_sudo" ]; then
		dpkg --add-architecture i386
		apt-get update
		apt-get install -y git cmake libmariadb-dev:i386 libssl-dev:i386 grep g++-6 g++-6-multilib mysql-client
		ln -s /usr/include/mariadb /usr/include/mysql
		rm -rf /var/lib/apt/lists/*
	else
		sudo dpkg --add-architecture i386
		sudo apt-get update
		sudo apt-get install -y git cmake libmariadb-dev:i386 libssl-dev:i386 grep g++-6 g++-6-multilib mysql-client
		sudo ln -s /usr/include/mariadb /usr/include/mysql
		sudo rm -rf /var/lib/apt/lists/*
	fi
fi

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
cmake .. -DCMAKE_CXX_COMPILER=g++-6 -DMARIA_LIBRARY=/usr/lib/i386-linux-gnu/libmariadb.so.3
make
mv src/BSQL/libBSQL.so "$1/"
cp /usr/lib/i386-linux-gnu/libmariadb.so.3 "$1/"
cd ../..

if [ ! -d "../GameStaticFiles/config" ]; then
	echo "Creating initial config..."
	cp -r "$1/config" "../GameStaticFiles/config"
	echo -e "SQL_ENABLED\nFEEDBACK_TABLEPREFIX SS13_\nADDRESS mariadb\nPORT 3306\nFEEDBACK_DATABASE ss13_db\nFEEDBACK_LOGIN root\nFEEDBACK_PASSWORD $MYSQL_ROOT_PASSWORD\nASYNC_QUERY_TIMEOUT 10\nBLOCKING_QUERY_TIMEOUT 5\nBSQL_THREAD_LIMIT 50" > "../GameStaticFiles/config/dbconfig.txt"
	echo "$TGS_ADMIN_CKEY = Host" > "../GameStaticFiles/config/admins.txt"
fi

if [ "$DATABASE_EXISTS" != "ss13_db" ]; then
	echo "Creating initial SS13 database..."
    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h mariadb -P 3306 -e 'CREATE DATABASE IF NOT EXISTS ss13_db;'
	cat "$1/$TGS_PREFIXED_SCHEMA_FILE"
    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h mariadb -P 3306 ss13_db < "$1/$TGS_PREFIXED_SCHEMA_FILE"
    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h mariadb -P 3306 ss13_db -e "INSERT INTO \`SS13_schema_revision\` (\`major\`, \`minor\`) VALUES ($TGS_SCHEMA_MAJOR_VERSION, $TGS_SCHEMA_MINOR_VERSION)"
fi

#just trust me, i nearly lost my shit
rm -rf "$1/byond-extools.dll"
