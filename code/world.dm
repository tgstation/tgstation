/world
	mob = /mob/new_player
	turf = /turf/open/space
	area = /area/space
	view = "15x15"
	cache_lifespan = 7
	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "/tg/ Station 13"
	fps = 20
	visibility = 0

var/list/map_transition_config = MAP_TRANSITION_CONFIG

/world/New()
	map_ready = 1
	world.log << "Map is ready."

#if (PRELOAD_RSC == 0)
	external_rsc_urls = file2list("config/external_rsc_urls.txt","\n")
	var/i=1
	while(i<=external_rsc_urls.len)
		if(external_rsc_urls[i])
			i++
		else
			external_rsc_urls.Cut(i,i+1)
#endif
	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diaryofmeanpeople = file("data/logs/[date_string] Attack.log")
	diary << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"
	diaryofmeanpeople << "\n\nStarting up. [time2text(world.timeofday, "hh:mm.ss")]\n---------------------"
	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently

	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)
	load_configuration()
	load_mode()
	load_motd()
	load_admins()
	if(config.usewhitelist)
		load_whitelist()
	LoadBans()
	investigate_reset()

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		config.server_name += " #[(world.port % 1000) / 100]"

	timezoneOffset = text2num(time2text(0,"hh")) * 36000

	if(config.sql_enabled)
		if(!setup_database_connection())
			world.log << "Your server failed to establish a connection with the database."
		else
			world.log << "Database connection established."


	data_core = new /datum/datacore()

	SortAreas()						//Build the list of all existing areas and sort it alphabetically
	process_teleport_locs()			//Sets up the wizard teleport locations

	#ifdef MAP_NAME
	map_name = "[MAP_NAME]"
	#else
	map_name = "Unknown"
	#endif

	Master.Setup(10, FALSE)


#define IRC_STATUS_THROTTLE 50
var/last_irc_status = 0

/world/Topic(T, addr, master, key)
	if(config && config.log_world_topic)
		diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	var/list/input = params2list(T)
	var/key_valid = (global.comms_allowed && input["key"] == global.comms_key)

	if("ping" in input)
		var/x = 1
		for (var/client/C in clients)
			x++
		return x

	else if("players" in input)
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if("ircstatus" in input)
		if(world.time - last_irc_status < IRC_STATUS_THROTTLE)
			return
		var/list/adm = get_admin_counts()
		var/status = "Admins: [adm["total"]] (Active: [adm["present"]] AFK: [adm["afk"]] Stealth: [adm["stealth"]] Skipped: [adm["noflags"]]). "
		status += "Players: [clients.len] (Active: [get_active_player_count(0,1,0)]). Mode: [ticker.mode.name]."
		send2irc("Status", status)
		last_irc_status = world.time

	else if("status" in input)
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["active_players"] = get_active_player_count()
		s["players"] = clients.len
		s["revision"] = revdata.commit
		s["revision_date"] = revdata.date

		var/list/adm = get_admin_counts()
		s["admins"] = adm["present"] + adm["afk"] //equivalent to the info gotten from adminwho
		s["gamestate"] = 1
		if(ticker)
			s["gamestate"] = ticker.current_state

		s["map_name"] = map_name ? map_name : "Unknown"

		if(key_valid && ticker && ticker.mode)
			s["real_mode"] = ticker.mode.name
			// Key-authed callers may know the truth behind the "secret"

		s["security_level"] = get_security_level()
		s["round_duration"] = round((world.time-round_start_time)/10)
		// Amount of world's ticks in seconds, useful for calculating round duration

		if(SSshuttle && SSshuttle.emergency)
			s["shuttle_mode"] = SSshuttle.emergency.mode
			// Shuttle status, see /__DEFINES/stat.dm
			s["shuttle_timer"] = SSshuttle.emergency.timeLeft()
			// Shuttle timer, in seconds

		return list2params(s)

	else if("announce" in input)
		if(!key_valid)
			return "Bad Key"
		else
#define CHAT_PULLR	64 //defined in preferences.dm, but not available here at compilation time
			for(var/client/C in clients)
				if(C.prefs && (C.prefs.chat_toggles & CHAT_PULLR))
					C << "<span class='announce'>PR: [input["announce"]]</span>"
#undef CHAT_PULLR

	else if("crossmessage" in input)
		if(!key_valid)
			return
		else
			if(input["crossmessage"] == "Ahelp")
				relay_msg_admins("<span class='adminnotice'><b><font color=red>HELP: </font> [input["source"]] [input["message_sender"]]: [input["message"]]</b></span>")
			if(input["crossmessage"] == "Comms_Console")
				minor_announce(input["message"], "Incoming message from [input["message_sender"]]")
				for(var/obj/machinery/computer/communications/CM in machines)
					CM.overrideCooldown()
			if(input["crossmessage"] == "News_Report")
				minor_announce(input["message"], "Breaking Update From [input["message_sender"]]")

	else if("adminmsg" in input)
		if(!key_valid)
			return "Bad Key"
		else
			return IrcPm(input["adminmsg"],input["msg"],input["sender"])

	else if("namecheck" in input)
		if(!key_valid)
			return "Bad Key"
		else
			log_admin("IRC Name Check: [input["sender"]] on [input["namecheck"]]")
			message_admins("IRC name checking on [input["namecheck"]] from [input["sender"]]")
			return keywords_lookup(input["namecheck"],1)
	else if("adminwho" in input)
		if(!key_valid)
			return "Bad Key"
		else
			return ircadminwho()


/world/Reboot(var/reason, var/feedback_c, var/feedback_r, var/time)
	if (reason == 1) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		world << "<span class='boldannounce'>Rebooting World immediately due to host request</span>"
		return ..(1)
	var/delay
	if(time)
		delay = time
	else
		delay = config.round_end_countdown * 10
	if(ticker.delay_end)
		world << "<span class='boldannounce'>An admin has delayed the round end.</span>"
		return
	world << "<span class='boldannounce'>Rebooting World in [delay/10] [delay > 10 ? "seconds" : "second"]. [reason]</span>"
	var/round_end_sound_sent = FALSE
	if(ticker.round_end_sound)
		round_end_sound_sent = TRUE
		for(var/thing in clients)
			var/client/C = thing
			if (!C)
				continue
			C.Export("##action=load_rsc", ticker.round_end_sound)
	sleep(delay)
	if(ticker.delay_end)
		world << "<span class='boldannounce'>Reboot was cancelled by an admin.</span>"
		return
	if(mapchanging)
		world << "<span class='boldannounce'>Map change operation detected, delaying reboot.</span>"
		rebootingpendingmapchange = 1
		spawn(1200)
			if(mapchanging)
				mapchanging = 0 //map rotation can in some cases be finished but never exit, this is a failsafe
				Reboot("Map change timed out", time = 10)
		return
	OnReboot(reason, feedback_c, feedback_r, round_end_sound_sent)
	..(0)

/world/proc/OnReboot(reason, feedback_c, feedback_r, round_end_sound_sent)
	feedback_set_details("[feedback_c]","[feedback_r]")
	log_game("<span class='boldannounce'>Rebooting World. [reason]</span>")
	kick_clients_in_lobby("<span class='boldannounce'>The round came to an end with you in the lobby.</span>", 1) //second parameter ensures only afk clients are kicked
#ifdef dellogging
	var/log = file("data/logs/del.log")
	log << time2text(world.realtime)
	for(var/index in del_counter)
		var/count = del_counter[index]
		if(count > 10)
			log << "#[count]\t[index]"
#endif
	var/soundwait = 0
	if (ticker.round_end_sound && !round_end_sound_sent)
		soundwait = 10
		for(var/thing in clients)
			var/client/C = thing
			if (!C)
				continue
			C.Export("##action=load_rsc", ticker.round_end_sound)
	spawn(soundwait/2)
		if(ticker && ticker.round_end_sound)
			world << sound(ticker.round_end_sound)
		else
			world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg','sound/misc/leavingtg.ogg', 'sound/misc/its_only_game.ogg', 'sound/misc/yeehaw.ogg')) // random end sounds!! - LastyBatsy
	if(blackbox)
		blackbox.save_all_data_to_sql()
	sleep(soundwait)
	Master.Shutdown()	//run SS shutdowns
	for(var/thing in clients)
		var/client/C = thing
		if (!C)
			continue
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

var/inerror = 0
/world/Error(var/exception/e)
	//runtime while processing runtimes
	if (inerror)
		inerror = 0
		return ..(e)
	inerror = 1
	//newline at start is because of the "runtime error" byond prints that can't be timestamped.
	e.name = "\n\[[time2text(world.timeofday,"hh:mm:ss")]\][e.name]"

	//this is done this way rather then replace text to pave the way for processing the runtime reports more thoroughly
	//	(and because runtimes end with a newline, and we don't want to basically print an empty time stamp)
	var/list/split = splittext(e.desc, "\n")
	for (var/i in 1 to split.len)
		if (split[i] != "")
			split[i] = "\[[time2text(world.timeofday,"hh:mm:ss")]\][split[i]]"
	e.desc = jointext(split, "\n")
	inerror = 0
	return ..(e)

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			diary << "Saved mode is '[master_mode]'"

/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")
	join_motd += "<br>"
	for(var/line in revdata.testmerge)
		if(line)
			join_motd += "Test merge active of PR <a href='[config.githuburl]/pull/[line]'>#[line]</a><br>"

/world/proc/load_configuration()
	protected_config = new /datum/protected_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	if (config.maprotation && SERVERTOOLS)
		config.loadmaplist("config/maps.txt")

	// apply some settings from config..
	abandon_allowed = config.respawn


/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "

	s += "<b>[station_name()]</b>";
	s += " ("
	s += "<a href=\"http://\">" //Change this to wherever you want the hub to link to.
//	s += "[game_version]"
	s += "Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += ")"

	var/list/features = list()

	if(ticker)
		if(master_mode)
			features += master_mode
	else
		features += "<b>STARTING</b>"

	if (!enter_allowed)
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"

	if (!host && config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

	status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0

/proc/setup_database_connection()

	if(failed_db_connections >= FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		if(config.sql_enabled)
			world.log << "SQL error: " + dbcon.ErrorMsg()

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
/proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF


/proc/maprotate()
	if (!SERVERTOOLS)
		return
	var/players = clients.len
	var/list/mapvotes = list()
	//count votes
	for (var/client/c in clients)
		var/vote = c.prefs.preferred_map
		if (!vote)
			if (config.defaultmap)
				mapvotes[config.defaultmap.name] += 1
			continue
		mapvotes[vote] += 1

	//filter votes
	for (var/map in mapvotes)
		if (!map)
			mapvotes.Remove(map)
		if (!(map in config.maplist))
			mapvotes.Remove(map)
			continue
		var/datum/votablemap/VM = config.maplist[map]
		if (!VM)
			mapvotes.Remove(map)
			continue
		if (VM.voteweight <= 0)
			mapvotes.Remove(map)
			continue
		if (VM.minusers > 0 && players < VM.minusers)
			mapvotes.Remove(map)
			continue
		if (VM.maxusers > 0 && players > VM.maxusers)
			mapvotes.Remove(map)
			continue

		mapvotes[map] = mapvotes[map]*VM.voteweight

	var/pickedmap = pickweight(mapvotes)
	if (!pickedmap)
		return
	var/datum/votablemap/VM = config.maplist[pickedmap]
	message_admins("Randomly rotating map to [VM.name]([VM.friendlyname])")
	. = changemap(VM)
	if (. == 0)
		world << "<span class='boldannounce'>Map rotation has chosen [VM.friendlyname] for next round!</span>"

var/datum/votablemap/nextmap
var/mapchanging = 0
var/rebootingpendingmapchange = 0
/proc/changemap(var/datum/votablemap/VM)
	if (!SERVERTOOLS)
		return
	if (!istype(VM))
		return
	mapchanging = 1
	log_game("Changing map to [VM.name]([VM.friendlyname])")
	var/file = file("setnewmap.bat")
	file << "\nset MAPROTATE=[VM.name]\n"
	. = shell("..\\bin\\maprotate.bat")
	mapchanging = 0
	switch (.)
		if (null)
			message_admins("Failed to change map: Could not run map rotator")
			log_game("Failed to change map: Could not run map rotator")
		if (0)
			log_game("Changed to map [VM.friendlyname]")
			nextmap = VM
		//1x: file errors
		if (11)
			message_admins("Failed to change map: File error: Map rotator script couldn't find file listing new map")
			log_game("Failed to change map: File error: Map rotator script couldn't find file listing new map")
		if (12)
			message_admins("Failed to change map: File error: Map rotator script couldn't find tgstation-server framework")
			log_game("Failed to change map: File error: Map rotator script couldn't find tgstation-server framework")
		//2x: conflicting operation errors
		if (21)
			message_admins("Failed to change map: Conflicting operation error: Current server update operation detected")
			log_game("Failed to change map: Conflicting operation error: Current server update operation detected")
		if (22)
			message_admins("Failed to change map: Conflicting operation error: Current map rotation operation detected")
			log_game("Failed to change map: Conflicting operation error: Current map rotation operation detected")
		//3x: external errors
		if (31)
			message_admins("Failed to change map: External error: Could not compile new map:[VM.name]")
			log_game("Failed to change map: External error: Could not compile new map:[VM.name]")

		else
			message_admins("Failed to change map: Unknown error: Error code #[.]")
			log_game("Failed to change map: Unknown error: Error code #[.]")
	if(rebootingpendingmapchange)
		world.Reboot("Map change finished", time = 10)
