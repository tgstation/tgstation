#!/bin/bash
set -euo pipefail

tools/deploy.sh ci_test
mkdir ci_test/config

#test config
cp -r config/* ci_test/config/
mv ci_test/config/config.txt ci_test/config/original_config.txt
cp tools/ci/ci_config.txt ci_test/config/config.txt

cd ci_test
DreamDaemon tgstation.dmb -close -trusted -verbose -params "log-directory=ci&original_config=original_config.txt"
cd ..
cat ci_test/data/logs/ci/clean_run.lk
