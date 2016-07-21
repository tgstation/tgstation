@echo off
echo node.js and all dependencies must be installed for this script to work.
echo If this script fails try installing dependencies again.
REM Build minified assets
cmd /c gulp --min
pause
