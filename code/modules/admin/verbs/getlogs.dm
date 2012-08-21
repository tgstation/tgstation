/*
	HOW DO I LOG RUNTIMES?
	Firstly, start dreamdeamon if it isn't already running. Then select "world>Log Session" (or press the F3 key)
	navigate the popup window to the data/logs/runtime/ folder from where your tgstation .dmb is located.
	(you may have to make this folder yourself)

	OPTIONAL: 	you can select the little checkbox down the bottom to make dreamdeamon save the log everytime you
				start a world. Just remember to repeat these steps with a new name when you update to a new revision!

	Save it with the name of the revision your server uses (e.g. r3459.txt).
	Game Masters will now be able to grant access any runtime logs you have archived this way!
	This will allow us to gather information on bugs across multiple servers and make maintaining the TG
	codebase for the entire /TG/station commuity a TONNE easier :3 Thanks for your help!
*/

#define FTPDELAY	600	//600 tick delay to discourage spam
/*
	These procs have failsafes built in to prevent spamming of file requests. As such it can only be used once every
	[FTPDELAY] ticks. This can be changed by modifying FTPDELAY's value above.

	PLEASE USE RESPONSIBLY, only download from the server if the log isn't already available elsewhere!
	Bandwidth is expensive and lags are lame. Some log files canr each sizes of 4MB!
*/

//This proc allows Game Masters to grant a client access to the .getruntimelog verb
//Permissions expire at the end of each round.
//Runtimes can be used to meta or spot game-crashing exploits so it's advised to only grant coders that
//you trust access. Also, it may be wise to ensure that they are not going to play in the current round.
/client/proc/giveruntimelog()
	set name = ".giveruntimelog"
	set desc = "Give somebody access to any session logfiles saved to the /log/runtime/ folder."
	set category = null

	if( !src.holder )
		src << "<font color='red'>Only Game Masters may use this command.</font>"
		return

	var/list/clients = list()
	for(var/client/C)
		clients += C

	var/client/target = input(src,"Choose somebody to grant access to the server's runtime logs (permissions expire at the end of each round):","Grant Permissions",null) as null|anything in clients
	if( !target || !istype(target,/client) )
		src << "<font color='red'>Error: giveruntimelog(): Client not found.</font>"
		return

	target.verbs |= /client/proc/getruntimelog
	target << "<font color='red'>You have been granted access to runtime logs. Please use them responsibly or risk being banned.</font>"
	return

//This proc allows download of runtime logs saved within the data/logs/ folder by dreamdeamon.
//It works similarly to show-server-log.
/client/proc/getruntimelog()
	set name = ".getruntimelog"
	set desc = "Retrieve any session logfiles saved by dreamdeamon."
	set category = null

	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		src << "<font color='red'>Error: getruntimelog(): spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>"
		return
	fileaccess_timer = world.time + FTPDELAY

	var/path = "data/logs/runtime/"

	var/list/path_list = flist(path)
	var/choice = input(src,"Choose a runtime-log to download:","Download",null) as null|anything in path_list
	if(!choice)				return

	path += "[choice]"
	if(!fexists(path))
		src << "<font color='red'>Error: getruntimelog(): Files not found/Invalid file([path]).</font>"
		return

	message_admins("[src] accessed runtime log: [path]")
	src << run( file(path) )
	return

//This proc allows download of past server logs saved within the data/logs/ folder.
//It works similarly to show-server-log.
/client/proc/getserverlog()
	set name = ".getserverlog"
	set desc = "Like 'Show Server Log' but it fetches old logs if there are any."
	set category = null

	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		src << "<font color='red'>Error: getserverlog(): spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>"
		return
	fileaccess_timer = world.time + FTPDELAY

	var/path = "data/logs/"
	for(var/i=0, i<4, i++)	//only bother searching up to 4 sub-directories. If we don't find it by then: give up.
		var/list/path_list = flist(path)
		if(path_list.len)	path_list -= "runtime/"
		else				break

		var/choice = input(src,"Choose a directory to access:","Download",null) as null|anything in path_list
		if(!choice)			return

		path += "[choice]"

		if( text2ascii(choice,length(choice)) != 47 )	//not a directory, finish up
			if(!fexists(path))
				src << "<font color='red'>Error: getserverlog(): File not found/Invalid file([path]).</font>"
				return
			src << run( file(path) )
			return
	return


//Other log stuff put here for the sake of organisation

//Shows today's server log
/obj/admins/proc/view_txt_log()
	set category = "Admin"
	set name = "Show Server Log"
	set desc = "Shows today's server log."

	var/path = "data/logs/[time2text(world.realtime,"YYYY/MM-Month/DD-Day")].log"
	if( fexists(path) )
		src << run( file(path) )
	else
		src << "<font color='red'>Error: view_txt_log(): File not found/Invalid path([path]).</font>"
		return
	feedback_add_details("admin_verb","VTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

//Shows today's attack log
/obj/admins/proc/view_atk_log()
	set category = "Admin"
	set name = "Show Server Attack Log"
	set desc = "Shows today's server attack log."

	var/path = "data/logs/[time2text(world.realtime,"YYYY/MM-Month/DD-Day")] Attack.log"
	if( fexists(path) )
		src << run( file(path) )
	else
		src << "<font color='red'>Error: view_atk_log(): File not found/Invalid path([path]).</font>"
		return
	usr << run( file(path) )
	feedback_add_details("admin_verb","SSAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
