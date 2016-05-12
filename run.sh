#!/bin/bash
set -e
(cd tgui; ./build.sh)
DreamMaker tgstation.dme
DreamDaemon tgstation.dmb 25001 -trace -trusted 2>&1 | tee server.log~
