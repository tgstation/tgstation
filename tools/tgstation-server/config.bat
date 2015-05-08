rem Server Tools configuration file. Lines starting with rem are comments and ignored.

rem This must be set to the name of your dme without the .dme part. (should be fine leaving this alone unless you renamed the code)
set PROJECTNAME=tgstation

rem location of the repo.
set REPO_URL=https://github.com/tgstation/-tg-station.git

rem what map file to use. This should be the name of the dm, not dmm (and without the .dm part)
set MAPFILE=metastation
rem set MAPFILE=metastation
rem set MAPFILE=ministation


set PORT=31337

rem This is the channel to log updates to. Leave blank to log to the normal channel
set UPDATE_LOG_CHANNEL=#coderbus

rem location of git. The script will attempt to auto detect this, but if it fails, you can set it manually.
rem This will be added to the end of path as is (only for the batch file, not the whole system)
rem github for windows users see http://www.chambaud.com/2013/07/08/adding-git-to-path-when-using-github-for-windows/ (an example is provided below)

set GIT_LOCATION_PATH=
rem set GIT_LOCATION_PATH=C:\Users\<user>\AppData\Local\GitHub\PortableGit_<guid>\bin;C:\Users\<user>\AppData\Local\GitHub\PortableGit_<guid>\cmd

rem path to the byond bin folder. (same rules as git path above)
set BYOND_LOCATION_PATH=