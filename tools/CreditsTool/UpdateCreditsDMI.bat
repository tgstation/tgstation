@echo off
rem do this too often and youll hit github's anonymous rate limit, add an `--authToken` parameter to bypass this. It doesn't require any scopes
cd github-contributors-list/bin
npm install
node githubcontributors --owner tgstation --repo tgstation --sortOrder desc --layoutStrategy ../lib/layout_strategies/json.js > ../../contributors.json

rem sudo code
rem load json entries
rem copy ___EMPTY.dmi___ to icons/credits.dmi
rem for each json entry
rem     download gravatar, size 25
rem     dmitool import icons/credits.dmi user_name gravatar 