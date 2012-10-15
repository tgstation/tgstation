
var/jsonpath = "/home/bay12/public_html"
var/dmepath = "/home/bay12/git/baystation12.dme"
var/makejson = 1 //temp
proc/makejson()

	if(!makejson)
		return
	fdel("[jsonpath]/info.json")
		//usr << "Error cant delete json"
	//else
		//usr << "Deleted json in public html"
	fdel("info.json")
		//usr << "error cant delete local json"
	//else
		//usr << "Deleted local json"
	var/F = file("info.json")
	if(!isfile(F))
		return
	var/mode
	if(ticker)
		if(ticker.current_state == 1)
			mode = "Round Setup"
		else if(ticker.hide_mode)
			mode = "SECRET"
		else
			mode = master_mode
	var/playerscount = 0
	var/players = ""
	var/admins = "no"
	for(var/client/C)
		playerscount++
		if(C.holder && C.holder.level >= 0)		// make sure retired admins don't make nt think admins are on
			if(!C.stealth)
				admins = "yes"
				players += "[C.key];"
			else
				players += "[C.fakekey];"
		else
			players += "[C.key];"
	F << "{\"mode\":\"[mode]\",\"players\" : \"[players]\",\"playercount\" : \"[playerscount]\",\"admin\" : \"[admins]\",\"time\" : \"[time2text(world.realtime,"MM/DD - hh:mm")]\"}"
	fcopy("info.json","[jsonpath]/info.json")

/proc/switchmap(newmap,newpath)
	var/oldmap
	var/obj/mapinfo/M = locate()

	if(M)
		oldmap = M.mapname

	else
		message_admins("Did not locate mapinfo object. Go bug the mapper to add a /obj/mapinfo to their map!\n For now, you can probably spawn one manually. If you do, be sure to set it's mapname var correctly, or else you'll just get an error again.")
		return

	message_admins("Current map: [oldmap]")
	var/text = file2text(dmepath)
	var/path = "#include \"maps/[oldmap].dmm\""
	var/xpath = "#include \"maps/[newpath].dmm\""
	var/loc = findtext(text,path,1,0)
	if(!loc)
		path = "#include \"maps\\[oldmap].dmm\""
		xpath = "#include \"maps\\[newpath].dmm\""
		loc = findtext(text,path,1,0)
		if(!loc)
			message_admins("Could not find '#include \"maps\\[oldmap].dmm\"' or '\"maps/[oldmap].dmm\"' in the bs12.dme. The mapinfo probably has an incorrect mapname var. Alternatively, could not find the .dme itself, at [dmepath].")
			return

	var/rest = copytext(text, loc + length(path))
	text = copytext(text,1,loc)
	text += "\n[xpath]"
	text += rest
/*	for(var/A in lines)
		if(findtext(A,path,1,0))
			lineloc = lines.Find(A,1,0)
			lines[lineloc] = xpath
			world << "FOUND"*/
	fdel(dmepath)
	var/file = file(dmepath)
	file << text
	message_admins("Compiling...")
	shell("./recompile")
	message_admins("Done")
	world.Reboot("Switching to [newmap]")

obj/mapinfo
	invisibility = 101
	var/mapname = "thismap"
	var/decks = 4
proc/GetMapInfo()
//	var/obj/mapinfo/M = locate()
//	Just removing these to try and fix the occasional JSON -> WORLD issue.
//	world << M.name
//	world << M.mapname
client/proc/ChangeMap(var/X as text)
	set name = "Change Map"
	set category  = "Admin"
	switchmap(X,X)
proc/send2adminirc(channel,msg)
	world << channel << " "<< msg
	shell("python nudge.py '[channel]' [msg]")