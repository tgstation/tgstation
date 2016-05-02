call bin\findgit.bat
echo Updating repo
cd gitrepo
git branch backup-%CUR_DATE% >nul 2>nul
git fetch
set GIT_EXIT=%ERRORLEVEL%
if %GIT_EXIT% neq 0 goto END
git checkout %REPO_BRANCH%
set GIT_EXIT=%ERRORLEVEL%
if %GIT_EXIT% neq 0 goto END
git reset origin/%REPO_BRANCH% --hard
set GIT_EXIT=%ERRORLEVEL%
if %GIT_EXIT% neq 0 goto END
git pull --force
set GIT_EXIT=%ERRORLEVEL%

:END
cd ..