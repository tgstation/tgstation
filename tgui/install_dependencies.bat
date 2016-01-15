@echo off
echo This assumes you have NodeJS with NPM installed.
echo If this script fails due to permission or other I/O errors, try running it again first.
echo If you don't have the right tools installed you can close this window. If you want to continue, press the any key.
echo Note that this script may warn about an unsupported dependency. You can safely ignore this warning.
REM Install GULP globally
cmd /c npm install gulp-cli -g
REM Install local dependencies
cmd /c npm install
REM Remove old dependencies
cmd /c npm prune
REM Flatten the tree
cmd /c npm dedupe
pause