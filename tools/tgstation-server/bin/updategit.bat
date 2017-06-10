call bin\findgit.bat
echo Updating repo

cd gitrepo

git branch backup-%CUR_DATE% >nul 2>nul
git fetch
set GIT_EXIT=%ERRORLEVEL%

git reset origin/%REPO_BRANCH% --hard

cd ..