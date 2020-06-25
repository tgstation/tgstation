#!/bin/bash
set -euo pipefail

tools/deploy.sh travis_test
mkdir travis_test/config

#test config
mv travis_test/config/config.txt travis_test/config/original_config.txt
cp tools/travis/travis_config.txt travis_test/config/config.txt

cd travis_test
ln -s $HOME/libmariadb/libmariadb.so libmariadb.so
DreamDaemon tgstation.dmb -close -trusted -verbose -params "test-run&log-directory=travis&original_config=original_config.txt"
cd ..
cat travis_test/data/logs/travis/clean_run.lk
