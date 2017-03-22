/world
	mob = /mob/dead/new_player
	turf = /turf/basic
	area = /area/space
	view = "15x15"
	cache_lifespan = 7
	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "/tg/ Station 13"
	fps = 20
	visibility = 0
#ifdef GC_FAILURE_HARD_LOOKUP
	loop_checks = FALSE
#endif

/world/New()
	log_world("World loaded at [time_stamp()]")

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
	diary << "\n\nStarting up. [time_stamp()]\n---------------------"
	diaryofmeanpeople << "\n\nStarting up. [time_stamp()]\n---------------------"
	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently

	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)
	load_configuration()
	revdata.DownloadPRDetails()
	load_mode()
	load_motd()
	load_admins()
	if(config.usewhitelist)
		load_whitelist()
	LoadBans()
	investigate_reset()

	timezoneOffset = text2num(time2text(0,"hh")) * 36000

	if(config.sql_enabled)
		if(!dbcon.Connect())
			log_world("Your server failed to establish a connection with the database.")
		else
			log_world("Database connection established.")


	data_core = new /datum/datacore()

	Master.Initialize(10, FALSE)

#define IRC_STATUS_THROTTLE 50
/world/Topic(T, addr, master, key)
	if(config && config.log_world_topic)
		diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	var/list/input = params2list(T)
	var/key_valid = (global.comms_allowed && input["key"] == global.comms_key)
	var/static/last_irc_status = 0

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
		var/list/allmins = adm["total"]
		var/status = "Admins: [allmins.len] (Active: [english_list(adm["present"])] AFK: [english_list(adm["afk"])] Stealth: [english_list(adm["stealth"])] Skipped: [english_list(adm["noflags"])]). "
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
		var/list/presentmins = adm["present"]
		var/list/afkmins = adm["afk"]
		s["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho
		s["gamestate"] = 1
		if(ticker)
			s["gamestate"] = ticker.current_state

		s["map_name"] = SSmapping.config.map_name

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
					to_chat(C, "<span class='announce'>PR: [input["announce"]]</span>")
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
	else if("server_hop" in input)
		show_server_hop_transfer_screen(input["server_hop"])

#define WORLD_REBOOT(X) log_world("World rebooted at [time_stamp()]"); ..(X); return;
/world/Reboot(var/reason, var/feedback_c, var/feedback_r, var/time)
	if (reason == 1) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, "<span class='boldannounce'>Rebooting World immediately due to host request</span>")
		WORLD_REBOOT(1)
	var/delay
	if(time)
		delay = time
	else
		delay = config.round_end_countdown * 10
	if(ticker.delay_end)
		to_chat(world, "<span class='boldannounce'>An admin has delayed the round end.</span>")
		return
	to_chat(world, "<span class='boldannounce'>Rebooting World in [delay/10] [(delay >= 10 && delay < 20) ? "second" : "seconds"]. [reason]</span>")
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
		to_chat(world, "<span class='boldannounce'>Reboot was cancelled by an admin.</span>")
		return
	OnReboot(reason, feedback_c, feedback_r, round_end_sound_sent)
	WORLD_REBOOT(0)
#undef WORLD_REBOOT

/world/proc/OnReboot(reason, feedback_c, feedback_r, round_end_sound_sent)
	feedback_set_details("[feedback_c]","[feedback_r]")
	log_game("<span class='boldannounce'>Rebooting World. [reason]</span>")
#ifdef dellogging
	var/log = file("data/logs/del.log")
	log << time2text(world.realtime)
	for(var/index in del_counter)
		var/count = del_counter[index]
		if(count > 10)
			log << "#[count]\t[index]"
#endif
	if(blackbox)
		blackbox.save_all_data_to_sql()
	Master.Shutdown()	//run SS shutdowns
	RoundEndAnimation(round_end_sound_sent)
	kick_clients_in_lobby("<span class='boldannounce'>The round came to an end with you in the lobby.</span>", 1) //second parameter ensures only afk clients are kicked
	to_chat(world, "<span class='boldannounce'>Rebooting world...</span>")
	for(var/thing in clients)
		var/client/C = thing
		if(C && config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

/world/proc/RoundEndAnimation(round_end_sound_sent)
	set waitfor = FALSE
	var/round_end_sound
	if(!ticker && ticker.round_end_sound)
		round_end_sound = ticker.round_end_sound
		if (!round_end_sound_sent)
			for(var/thing in clients)
				var/client/C = thing
				if (!C)
					continue
				C.Export("##action=load_rsc", round_end_sound)
	else
		round_end_sound = pick(\
		'sound/roundend/newroundsexy.ogg',
		'sound/roundend/apcdestroyed.ogg',
		'sound/roundend/bangindonk.ogg',
		'sound/roundend/leavingtg.ogg',
		'sound/roundend/its_only_game.ogg',
		'sound/roundend/yeehaw.ogg',
		'sound/roundend/disappointed.ogg'\
		)

	for(var/thing in clients)
		var/obj/screen/splash/S = new(thing, FALSE)
		S.Fade(FALSE,FALSE)

	world << sound(round_end_sound)

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
	join_motd = file2text("config/motd.txt") + "<br>" + revdata.GetTestMergeInfo()

/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	if (config.maprotation)
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
