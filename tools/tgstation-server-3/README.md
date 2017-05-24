# Tgstation Toolkit 3:
This is a toolset to manage a production server of /tg/Station13 (and its forks). It includes the ability to update the server without having to stop or shutdown the server (the update will take effect next round) the ability start the server and restart it if it crashes, as well as systems for fixing errors and merging GitHub Pull Requests locally.
  
Generally, updates force a live tracking of the configured git repo, resetting local modifications. If you plan to make modifications, set up a new git repo to store your version of the code in, and point this script to that in the config (explained below). This can be on github or a local repo using file:/// urls.

Requires python 2.7 to be installed for changelog generation

## Install
1. Either compile from source (requires .NET Framework 4.5.2, Nuget, and WiX toolset 4.0) or download the latest release from github
1. Run the installer

## Install (GUI):
1. Launch TGControlPanel.exe. A shortcut can be found on your desktop
1. Optionally switch to the `Server` tab and change the Server Path location from C:\tgstation-server-3 to wherever you wish
1. Go to the `Repository` Tab and set the remote address and branch of the git you with to track
1. Hit the clone button
1. While waiting go to the BYOND tab and install the BYOND version you wish
1. You may also configure an IRC or discord bot for the server on the chat tab
1. Once the clone is complete you may set up a committer identity, user name, and password on the `Repository` tab for pushing changelog updates
1. Go to the `Server` tab and click the `Initialize Game Folders` button
1. Optionally change the `Project Path` Setting from tgstation to wherever the dme/dmb pair are in your repository
1. Optionally tick the Autostart box if you wish to have your server start with Windows
1. When game folder initialization is complete, click the `Copy from Repo and Compile` option

## Install (CL example):
This process is identical to the above steps in command line mode. You can always learn more about a command using `?` i.e. `repo ?`
1. Launch TGCommandLine.exe (running with no parameters puts you in interactive mode)
1. `config move-server D:\tgstation`
1. `repo setup https://github.com/tgstation/tgstation master`
1. `byond update 511.1382`
1. `chat set-provider irc`
1. `irc nick TGS3Test`
1. `irc setup-auth NickServ "id hunter2"` Yes this is the real password, please use it only for testing
1. `chat enable`
1. `repo set-name tgstation-server` These two lines specify the changelog's committer identity. They are not mirrored in the GUI
1. `repo set-email tgstation-server@tgstation13.org`
1. `repo set-credentials` And follow the prompts
1. `dm project-name tgstation`
1. `repo python-path C:\Python27`
1. `dd autostart on`
1. Use `repo status` To check the clone job status
1. `dm initialize --wait`
1. `dm compile --wait`
1. `dd start`

### Folders and Files (None of these should be touched):
* `Game/<A/B>/`
	* This will house two copies of the game code, one for updating and one for live. When updating, it will automatically swap them.

* `Static/`
	* This contains the `data/` and `config/` folders from the code. They are stored here and a symbolic link is created in the `gamecode/` folders pointing to here.
	* This also makes backing them up easy. (you may copy and paste your existing `data/` and `config/` folders here after the install script has ran.)
	* Resetting the repository will create a backup of this and reinitalize it

* `Game/Live/`
	* This is a symbolic link pointing to current "live" folder.
	* When the server is updated, we just point this to the updating folder so that the update takes place next round.

* `Repository/`
	* This contains the actual git repository, all changes in here will be overwritten during update operations, the configured branch will always be forced to track from live.
	* On the first update of the day, the current code state is saved to a branch called `backup-YYYY-MM-DD` before updating, to make local reverts easy.
	* Following update operations on the same day do not make branches because I was too lazy to detect such edge cases.

* `RepoKey/`
	* This contains ssh key information for automatic changelog pushing. 

* `BYOND/`
	* This contains the actual BYOND installation the server uses

* `BYOND_staging/`
	* This appears when a BYOND update is queued but can't currently be applied due to usage of the current BYOND version. It will be applied at the first possible moment. Restarting the service deletes this folder

* `BYOND_revision.zip`
	* This is a queued update downloaded from BYOND, it will be unzipped into BYOND_staging and deleted. Restarting the service deletes this file

* `prtestjob.json`
	* This contains information about current test merged pull requests in the Repository folder

### Starting the game server:
To run the game server, open the `Server` tab of the control panel and click either `Start`

It will restart the game server if it shutdowns for any reason, giving up after 5 tries in under a minute


### Updating the server:
To update the server, open the `Server` tab of the control panel. Optionally tick `Commit and push Changelogs`. Click `Update (Reset Testmerge)`. (it will git pull, compile, all that jazz)  

(Note: Updating automatically does a code reset, clearing ALL changes to the local git repo, including test merges (explained below) and manual changes (This will not change any configs/settings or clear any data in the `gamedata/` folder))  

Updates do not require the server to be shutdown, changes will apply next round if the server is currently running.  

All DM compilation will log to the server what commit they happened at

There is also a `Update (Keep Testmerge)` option that does the same without resetting the code, used to update without clearing test merges or local changes. Prone to merge conflicts.


### Locally merge GitHub Pull Requests (PR test merge):
This feature currently only works if github is the remote(git server), it could be adapted for gitlab as well.

Running these will merge the pull request then recompile the server, changes take effect the next round if the server is currently running.  

There are multiple flavors in the server tab:  
* `Update and Testmerge`
	* Updates the server, resetting state, and merges a PR(Pull Request) by number.
* `Testmerge`
	* Merges a PR without updating the server before hand or resetting the state (can be used to test merge multiple PRs).

You can clear all active test merges using `Reset to Origin Branch` in the `Repository` tab and the using `Copy from Repo and Compile` in the server tab (explained below)

### Resetting, Recompiling, and troubleshooting.
* `Server` -> `Copy from Repo and Compile`
	* Just recompiles the game code and stages it to apply next round
* `Server` -> `Reset and Recompile`
	* Like the above but resets the git repo to the state of the last update operation (clearing any changes or test merges) (Does not reset `gamedata/` data/settings)
	* Generally used to clear out test merges
* `Server` -> `Initialize Game Folders`
	* Requires the server not be running, rebuilds the staging A/B folders and then does `Copy from Repo and Compile`.
 
### Starting everything when the computer/server boots
* Just tick the `Autostart` option in the `Server` tab or run `dd autostart on` on the command line. As it's a windows service, it will automatically run without having to log ing

### Configuring
* The `Config` panel of the control panel lets you modify nearly all the game configuration settings
* Not all settings can be modified from here. Although, you should never (have to) write to the service's folders directly. Instead you may use the `Download` button to download a copy of the config file locally, modify it there, then use the `Upload` button to apply it to the `Static/config` folder. You may also use the `DL Repo` button to download from the `Repository` config folder.
* The above functions are the only ones available in command line mode using `config download <Static/config path> <local path>`, `config upload <Static/config path> <local path>`, and `config download <Repository/config path> <local path> --repo` respectively

### Viewing Server Logs
* Logs are stored in the Windows event viewer under `Windows Logs` -> `Application`. You'll need to filter this list for `TG Station Server`
* You can also import the custom view `View TGS3 Logs.xml` in this folder to have them automatically filtered

### Enabling upstream changelog generation
* The repository will automatically create an ssh version of the initial origin remote and can optionally push generated changelogs to your git through it
* The repository can only authenticate using ssh public key authentication
* To enable this feature, simply create `public_key.txt` and `private_key.txt` in a folder called RepoKey in the server directory
* The private key must be in `-----BEGIN RSA PRIVATE KEY-----` format and the public key must be in `ssh-rsa` format. See github guidelines for setting this up here: https://help.github.com/articles/connecting-to-github-with-ssh/
* The service will be able to read these files regardless of their permissions, so the responsibility is on you to set their ACL's so they can't be read by those that shouldn't

## CONTRIBUTING

* IF YOU MAKE ANY CHANGES TO THE CODE, BE SURE TO BUMP THE VERSION NUMBERS IN ALL 4 "AssemblyInfo.cs"s AND ON LINE 3 OF TGServiceInstaller/Product.wx
* My recommendation is bump the revision number per test release, the minor version per PR, and the major version if you rewrite the whole thing.
* To have auto deployment to github releases work, put `[TGSDeploy]` somewhere in your pull request title