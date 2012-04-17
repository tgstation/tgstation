/*
	HOW DO I LOG RUNTIMES?
	Firstly, start dreamdeamon if it isn't already running. Then select "world>Log Session" (or press the F3 key)
	navigate the popup window to the log/runtime/ folder from where your tgstation .dmb is located.

	OPTIONAL: 	you can select the little checkbox down the bottom to make dreamdeamon save the log everytime you
				start a world. Just remember to repeat these steps with a new name when you update to a new revision!

	Save it with the name of the revision your server uses (e.g. r3459.txt).
	Coders with the Game Master rank will now be able to access any runtime logs you have archived this way!
	This will allow us to gather information on bugs across multiple servers and make maintaining the TG
	codebase for the entire /TG/station commuity a TONNE easier :3 Thanks for your help!
*/
#define FTPDELAY	200	//20 second delay to prevent spam

//This proc allows GameMasters to download txt files saved to the log/runtime/ folder on the server.
//In effect this means the server owner can log game sessions through DreamDeamon to that folder and
//Coders (with access) can download logs (old and current).
//To make life easier on everyone please name logfiles according to the revision number in use!

//This proc has a failsafe built in to prevent spamming of ftp requests. As such it can only be used once every
//20 seconds. This can be changed by modifying FTPDELAY's value.

//PLEASE USE RESPONSIBLY, only download from the server if the log isn't already available elsewhere!
//Bandwidth is expensive and lags are lame. Although txt files of a few kB shouldn't cause problems really ~Carn

/client/proc/getruntimelog()
	set name = "getruntimelog"
	set desc = "Retrieve any session logfiles saved by dreamdeamon"
	set category = "Debug"
	set hidden = 1

	if( !src.holder || holder.rank != "Game Master" )
		src << "<font color='red'>Only Game Masters may use this command.</font>"
		return

	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		src << "<font color='red'>Error: getruntimelog(): FTP-request spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>"
		return
	fileaccess_timer = world.time + FTPDELAY

	var/list/list_of_runtimelogs = flist("log/runtime/")
	var/choice = input(src,"Choose a runtime-log to download:","Download",null) in list_of_runtimelogs

	if(!choice || !fexists("log/runtime/[choice]"))
		src << "<font color='red'>Error: getruntimelog(): Files not found/Invalid file([choice]).</font>"
		return

	src << ftp("log/runtime/[choice]")

	return

