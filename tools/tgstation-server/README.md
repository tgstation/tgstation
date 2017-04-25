# Tgstation Toolkit:
This is a toolset to manage a production server of /tg/Station13 (and its forks). It includes an update script that is able to update the server without having to stop or shutdown the server (the update will take effect next round) and a script to start the server and restart it if it crashes (optional, requires registry tweaks to disable the Windows crash dialog system wide) as well as systems for fixing errors and merging GitHub Pull Requests locally.
  
Generally, updates force a live tracking of the configured git repo, resetting local modifications. If you plan to make modifications, set up a new git repo to store your version of the code in, and point this script to that in the config (explained below). This can be on github or a local repo using file:/// urls.

These tools require UAC to be disabled. (There has been limited luck getting it to work under UAC on windows 10 using run as admin, but in other versions of windows, running as admin resets the current directory and this breaks things)
(Note: There is no security risk to disabling UAC because UAC is not a security boundary, there exists active unpatched exploits against it that have been around since vista and work up to windows 10)

## Install:
1. Move this folder to where you want your server to run from (you may also rename this folder if you wish)
1. Right click on `config.bat` and select `Edit`.
1. Configure the port, git repo, and other setting, You may configure the location of git, but if you installed using git for windows, we will auto detect it if its not in path.
1. You may also need to change the location of the git repo url, and if you renamed your `dme`/"dream maker environment" file, you will need to change the project name configuration setting to be the name of your dme minus the extension (eg: if you renamed `tgstation.dme` to `ntstation.dme`, project name should be set to `ntstation`
1. Finally, run install.bat and hope for no error.
	* It will clone the git repo, setup some folders, and add cross reference links everywhere.
	
### Optional:
If you plan to use the `Start Server.bat` script to start the server and restart it if it crashes, you need to run the `disable crash dialog.reg` registry script to disable the "program.exe has stopped working" dialog. This will get disabled system wide so if you rely on this dialog, you should skip this step.

## Usage:
### Folders:
* `gamecode/`
	* This will house two copies of the game code, one for updating and one for live. When updating, it will automatically swap them.

* `gamedata/`
	* This contains the `data/` and `config/` folders from the code. They are stored here and a symbolic link is created in the `gamecode/` folders pointing to here.
	* This also makes backing them up easy.
(you may copy and paste your existing `data/` and `config/` folders here after the install script has ran.)

* `bot/`
	* This is a copy of the bot folder. you should run the bot from here.a link to nudge.py is created in the code folders so that the game can use the announcement feature.
	* The start server script and update script will send messages out thru the bot, but if its not running or python is not installed, they will gracefully continue what they are doing.

* `gamefolder/`
	* This is a symbolic link pointing to current "live" folder.
	* When the server is updated, we just point this to the updating folder so that the update takes place next round.

* `gitrepo/`
	* This contains the actual git repository, all changes in here will be overwritten during update operations, the configured branch will always be forced to track from live.
	* On the first update of the day, the current code state is saved to a branch called `backup-YYYY-MM-DD` before updating, to make local reverts easy.
	* Following update operations on the same day do not make branches because I was too lazy to detect such edge cases.

* `bin/`
	* This contains random helper batch files.
	* Running these on their own is a bad idea.

### Starting the game server:
To run the game server, Run `Start Server.bat`

It will restart the game server if it shutdowns for any reason, with delays if the game server had recently been (re)started.


### Updating the server:
To update the server, just run `Update Server.bat`. (it will git pull, compile, all that jazz)  

(Note: Updating automatically does a code reset, clearing ALL changes to the local git repo, including test merges (explained below) and manual changes (This will not change any configs/settings or clear any data in the `gamedata/` folder))  

Updates do not require the server to be shutdown, changes will apply next round if the server is currently running.  

Updates create a branch with the current state of the repo called `backup-YYYY-MM-DD` (only one is created in any given day)

There is also a `Update without resetting.bat` file that does the same without resetting the code, used to update without clearing test merges or local changes. Prone to merge conflicts.


### Locally merge GitHub Pull Requests (PR test merge):
This feature currently only works if github is the remote(git server), it could be adapted for gitlab as well.

Running these will merge the pull request then recompile the server, changes take effect the next round if the server is currently running.  

There are multiple flavors:  
* `Update To PR.bat`
	* Updates the server, resetting state, and merges a PR(Pull Request) by number.
* `Merge PR Without Updating.bat`
	* Merges a PR without updating the server before hand or resetting the state (can be used to test merge multiple PRs).

You can clear all active test merges using `Reset and Recompile.bat` (explained below)

### Resetting, Recompiling, and troubleshooting.
* `Recompile.bat`
	* Just recompiles the game code and stages it to apply next round
* `Reset and Recompile.bat`
	* Like the above but resets the git repo to the state of the last update operation (clearing any changes or test merges) (Does not reset `gamedata/` data/settings)
	* Generally used to clear out test merges
* `Fix Errors.bat`
	* Requires the server not be running, rebuilds the staging A/B folders and then does all of the above. (Used to fix errors that can prevent the server from starting or cause it to crash on reboot)
 
### Using the bot
1. Install python 3
1. Edit the config in `bot/` as needed
1. Start the bot using the `Start Bot.bat` file

 
### Starting everything when the computer/server boots
1. Use autologin to set it up so the user account logs in at boot
	* (There are some security implications with doing this, this is only a tiny bit more secure then putting a file on the hard drive with the server's remote login password titled `totally not a password.txt`)
	* https://technet.microsoft.com/en-us/sysinternals/bb963905
1. Setup something to run OnServerBoot.bat on login (setting up a link/shortcut to this file in the startup folder of the start menu works, creating a scheduled task in windows administrative tools also works)
1. OnServerBoot.bat does not update, but it does re-compile and reinitialize the A/B folders.
	
### Updating byond after this is all setup
1. Download installer from byond website
1. Close watch dog/start server script
1. Wait for current round to end
1. Exit DreamDeamon
1. Run installer
1. After installing, run recompile.bat (or update if you want)
1. Run start server.bat



	
