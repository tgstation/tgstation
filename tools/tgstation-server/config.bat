@echo off
REM Server Tools configuration file. Lines starting with rem are comments and ignored.

REM This must be set to the name of your dme without the .dme part. (should be fine leaving this alone unless you renamed the code)
set PROJECTNAME=tgstation


REM location of the repo. (use an ssh url if you plan to push compiled changlogs)
REM Only set during install, do not re-run install.bat if you change this, instead manually change the remote of the gitrepo folder using git tools
set REPO_URL=https://github.com/tgstation/-tg-station.git


REM What branch of the repo to use.
set REPO_BRANCH=master


REM Override Map (This disables map roation and forces the selected map to always be loaded)
REM set MAPFILE=tgstation2
REM set MAPFILE=metastation


REM port to use when starting the server
set PORT=2337


REM This is the channel to log updates to. Leave blank to log to the bot's default logging channel (this is done via the tgstation minibot bot, optional)
set UPDATE_LOG_CHANNEL=#devbus,#coderbus,#tgstation13


REM Attempt to push the compiled changelog to the configured git server? (set to anything)
REM This requires you configure git with authentication for the upstream server. (git for windows users should just put an ssh key in c:\users\USERNAME_HERE\.ssh\ as the filename id_rsa) And you should have installed this with a git, ssh, or file url)
set PUSHCHANGELOGTOGIT=


REM location of git. The script will attempt to auto detect this, but if it fails, you can set it manually.
REM github for windows users see http://www.chambaud.com/2013/07/08/adding-git-to-path-when-using-github-for-windows/ (an example is provided below)

set GIT_LOCATION_PATH=
REM set GIT_LOCATION_PATH=C:\Users\Administrator\AppData\Local\GitHub\PortableGit_c2ba306e536fdf878271f7fe636a147ff37326ad\bin;C:\Users\Administrator\AppData\Local\GitHub\PortableGit_c2ba306e536fdf878271f7fe636a147ff37326ad\cmd

REM path to the byond bin folder. (same rules as git path above, almost always auto detected, but you could point this to the output of the zip version for install-less setups, and even abuse that to make updating byond versions less of a pain by just changing this config and then crashing the server.)
set BYOND_LOCATION_PATH=
