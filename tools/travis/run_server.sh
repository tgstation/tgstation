#!/bin/bash
set -euo pipefail

tools/deploy.sh travis_test
rm travis_test/*.dll
mkdir travis_test/config

#test config
cp tools/travis/travis_config.txt travis_test/config/config.txt

cd travis_test
DreamDaemon tgstation.dmb -close -trusted -verbose -params "log-directory=travis"
cd ..
cat travis_test/data/logs/travis/clean_run.lk
