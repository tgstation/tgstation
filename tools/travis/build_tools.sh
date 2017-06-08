#!/bin/bash

#must also be bash for the md5sum commands
set -e

if [ "$BUILD_TOOLS" = true ];
then
    md5sum -c - <<< "49bc6b1b9ed56c83cceb6674bd97cb34 *html/changelogs/example.yml";
    cd tgui && source ~/.nvm/nvm.sh && gulp && cd ..;
    jsonlint-cli ./**/*.json
    python tools/ss13_genchangelog.py html/changelog.html html/changelogs;
fi;
