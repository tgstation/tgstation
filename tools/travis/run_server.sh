#!/bin/bash
set -euo pipefail

tools/travis/dm.sh -DTRAVISBUILDING tgstation.dme

tools/deploy.sh travis_test
mkdir travis_test/config

#test config
cp tools/travis/travis_config.txt travis_test/config/config.txt

# get libmariadb, cache it so limmex doesn't get angery
if [ -f $HOME/libmariadb ]; then
	#travis likes to interpret the cache command as it being a file for some reason
	rm $HOME/libmariadb
fi
mkdir -p $HOME/libmariadb
if [ ! -f $HOME/libmariadb/libmariadb.so ]; then
	wget http://www.byond.com/download/db/mariadb_client-2.0.0-linux.tgz
	tar -xvf mariadb_client-2.0.0-linux.tgz
	mv mariadb_client-2.0.0-linux/libmariadb.so $HOME/libmariadb/libmariadb.so
	rm -rf mariadb_client-2.0.0-linux.tgz mariadb_client-2.0.0-linux
fi

cd travis_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
DreamDaemon tgstation.dmb -close -trusted -verbose -params "test-run&log-directory=travis"
cd ..
cat travis_test/data/logs/travis/clean_run.lk
