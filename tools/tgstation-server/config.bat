@echo off
REM Server Tools configuration file. Lines starting with rem are comments and ignored.


REM This must be set to the name of your dme without the .dme part. (should be fine leaving this alone unless you renamed the code)
set PROJECTNAME=tgstation


REM location of the repo.
set REPO_URL=https://github.com/tgstation/-tg-station.git


REM what map file to use. This should be the name of the dm, not dmm (and without the .dm part) (defaults to what ever is ticked in the dme)
set MAPFILE=tgstation2
REM set MAPFILE=metastation
REM set MAPFILE=ministation


REM port to use (only used to start the server in the start-server script)
set PORT=1337


REM This is the channel to log updates to. Leave blank to log to the normal channel (this is done via the tgstation bot, optional)
set UPDATE_LOG_CHANNEL=#coderbus


REM overrides the prompt to live apply the updates in update server.bat if set to anything other than a null string.
REM It is generally safe to live apply the updates, they don't take effect until the next round. the only concern is that some media files may get loaded by new clients before the next round. These files aren't edited 99% of the time, so its not a real concern, but I kept the prompt the default for compatibility sake.
set NOWAITUPDATES=


REM location of git. The script will attempt to auto detect this, but if it fails, you can set it manually.
REM This will be added to the end of path as is (only for the batch file, not the whole system)
REM github for windows users see http://www.chambaud.com/2013/07/08/adding-git-to-path-when-using-github-for-windows/ (an example is provided below)
set GIT_LOCATION_PATH=
REM set GIT_LOCATION_PATH=C:\Users\<user>\AppData\Local\GitHub\PortableGit_<guid>\bin;C:\Users\<user>\AppData\Local\GitHub\PortableGit_<guid>\cmd


REM path to the byond bin folder. (same rules as git path above)
set BYOND_LOCATION_PATH=

