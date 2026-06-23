#!/bin/bash
set -euo pipefail

MAP=$1

echo Testing $MAP

tools/deploy.sh ci_test

# Debug: verify compiled BT files were deployed
BT_COUNT=$(find ci_test/build/behavior_trees -name "*.compiled.json" 2>/dev/null | wc -l)
echo "DEBUG: $BT_COUNT compiled BT files in ci_test/build/behavior_trees/"
if [ "$BT_COUNT" -eq 0 ]; then
    echo "ERROR: No compiled BT files found after deploy — file2text() will fail at runtime"
    exit 1
fi

mkdir -p ci_test/config
mkdir -p ci_test/data

#test config
cp tools/ci/ci_config.txt ci_test/config/config.txt
cp tools/ci/ci_config_maps.txt ci_test/config/maps.txt

#set the map
cp _maps/$MAP.json ci_test/data/next_map.json

cd ci_test
DreamDaemon tgstation.dmb -close -trusted -verbose -params "log-directory=ci"

cd ..

mkdir -p data
if [ -d "ci_test/data/screenshots_new" ]; then
    mkdir -p data/screenshots_new
    cp -r ci_test/data/screenshots_new data/screenshots_new
fi
cp ci_test/data/unit_tests.json data/unit_tests.json

cat ci_test/data/logs/ci/clean_run.lk
