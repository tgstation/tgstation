About:
	This is a toolset to manage a production server of tgstation13 (or its forks). It includes an update script that is able to update the server without having to stop or shutdown the server (the update will take effect next round) and a script to start the server and restart it if it crashes (optional, requires registry tweaks to disable the Windows crash dialog system wide)
	
	This will force a live tracking of the configured git repo, so no local modifications are allowed. (this is to avoid issues with merge conflicts and because I'm too lazy to make the script detect them)
	

Install:
	Move this folder to where you want your server to run from (you may also rename this folder if you wish)
	Right click on config.bat and click edit.
	Configure the port, selected map file, and the like, You may configure the location of git, but if you installed using git for windows, we will auto detect it if its not in path.
	You may also need to change the location of the gitrepo url, and if you renamed your dme/"dream maker environment" file, you will need to change the project name configuration setting to be the name of your dme minus the extension (eg: if you renamed tgstation.dme to ntstation.dme, project name should be set to ntstation
	
	After that, just run install.bat and hope for no error.
	
	It will clone the git repo, setup some folders, and add cross reference links everywhere.
	
	Optional:
		If you plan to use the start-server script to watch the server and restart it if it crashes, you should run the "disable crash dialog.reg" registry script to disable the "program.exe has stopped working" dialog. This will get disabled system wide so if you rely on this dialog, you shouldn't run the script.
		Even without this, byond stopping the world from two many critical errors (like infinite loops and recursions) will still be detected.
	
Usage:
	The install script will make a few folders:
		gamecode
			This will house two copies of the game code, one for updating and one for live. When updating, it will automatically swap them.
		
		gamedata
			This contains the data, config, and cfg folders from the code. They are stored here and a symbolic link is created in the code folders pointing to here.
			This also makes backing them up easy.
			(you may copy and paste your existing data/config/cfg folders here after the install script has ran.)
		
		bot
			This is a copy of the bot folder. you should run the bot from here. a link to coredata.py and nudge.py is created in the code folders so that the game can use the announcement feature.
			The start server script and update script will send messages out thru the bot, but if its not running or python is not installed, they will gracefully continue what they are doing.
		
		gamefolder
			This is a symbolic link pointing to current "live" folder.
			When the server is updated, we just point this to the updating folder so that the update takes place next round.
		
		bin
			This contains random helper batch files.
			Running these on their own is a bad idea.
		
	To update the server, just run update server.bat. (it will git pull, compile, all that jazz)
		It will ask you if you want to apply the update live. 99.9% of the time, this will not cause issues. The only issues it can cause relate to changes to media files(images(but not icons)/css/html/sound not stored in the RSC. but only new clients will see those issues, and at worst, its a minor graphical glitch.
		You may remove the pause in the update script at line 90 if you like.
	
	To run the server, just run start server.bat
		It will automatically redirect the runtimes to data/logs/runtimes/runtime-YYYY-MM-DD.log.
			(Note: It will not automatically roll them over, but every time it crashes or stops it will have a new log file.)
		When it starts dreamdaemon, it instructs byond to close down dreamdaemon if the world stops for any reason, this includes hitting the stop button, dreamdaemon shutting the world down because of too many runtimes/infinite loops.
		If dreamdaemon ever stops while the start server script is running, the script will restart it automatically.
			(Note: The script can not detect hangs or lockups)
	
	
	
	