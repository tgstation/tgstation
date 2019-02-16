#!/bin/bash

#must also be bash for the md5sum commands
set -e

if [ "$BUILD_TOOLS" = true ];
then
    md5sum -c - <<< "49bc6b1b9ed56c83cceb6674bd97cb34 *html/changelogs/example.yml";
    (cd tgui && source ~/.nvm/nvm.sh && npm ci && node node_modules/gulp/bin/gulp.js --min)
    phpenv global 5.6
    php -l tools/WebhookProcessor/github_webhook_processor.php;
    php -l tools/TGUICompiler.php;
    echo "Checking for JSON errors";
    find . -name "*.json" -not -path "./tgui/node_modules/*" | xargs -0 python3 ./tools/json_verifier.py;
    python3 tools/ss13_genchangelog.py html/changelog.html html/changelogs;
fi;
