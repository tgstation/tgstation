/world
	mob = /mob/dead/new_player
	turf = /turf/open/space/basic
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
	external_rsc_urls = world.file2list("config/external_rsc_urls.txt","\n")
	var/i=1
	while(i<=external_rsc_urls.len)
		if(external_rsc_urls[i])
			i++
		else
			external_rsc_urls.Cut(i,i+1)
#endif
	GLOB.config_error_log = file("data/logs/config_error.log") //temporary file used to record errors with loading config, moved to log directory once logging is set bl
	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)
	config = new
	GLOB.log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM/DD")]/round-"
	if(config.sql_enabled)
		if(SSdbcore.Connect())
			log_world("Database connection established.")
			var/datum/DBQuery/query_feedback_create_round = SSdbcore.NewQuery("INSERT INTO [format_table_name("feedback")] SELECT null, Now(), MAX(round_id)+1, \"server_ip\", 0, \"[world.internet_address]:[world.port]\" FROM [format_table_name("feedback")]")
			query_feedback_create_round.Execute()
			var/datum/DBQuery/query_feedback_max_id = SSdbcore.NewQuery("SELECT MAX(round_id) FROM [format_table_name("feedback")]")
			query_feedback_max_id.Execute()
			if(query_feedback_max_id.NextRow())
				GLOB.round_id = query_feedback_max_id.item[1]
				GLOB.log_directory += "[GLOB.round_id]"
		else
			log_world("Your server failed to establish a connection with the database.")
	if(!GLOB.round_id)
		GLOB.log_directory += "[replacetext(time_stamp(), ":", ".")]"
	GLOB.world_game_log = file("[GLOB.log_directory]/game.log")
	GLOB.world_attack_log = file("[GLOB.log_directory]/attack.log")
	GLOB.world_runtime_log = file("[GLOB.log_directory]/runtime.log")
	GLOB.world_href_log = file("[GLOB.log_directory]/hrefs.html")
	GLOB.world_game_log << "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------"
	GLOB.world_attack_log << "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------"
	GLOB.world_runtime_log << "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------"
	GLOB.changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently
	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	GLOB.revdata.DownloadPRDetails()
	load_mode()
	load_motd()
	load_admins()
	hippie_initialize()
	load_menu()
	if(config.usewhitelist)
		load_whitelist()
	LoadBans()

	GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	GLOB.data_core = new /datum/datacore()

	Master.Initialize(10, FALSE)

#define IRC_STATUS_THROTTLE 50
/world/Topic(T, addr, master, key)
	if(config && config.log_world_topic)
		GLOB.world_game_log << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	var/list/input = params2list(T)
	var/key_valid = (global.comms_allowed && input["key"] == global.comms_key)
	var/static/last_irc_status = 0

	if("ping" in input)
		var/x = 1
		for (var/client/C in GLOB.clients)
			x++
		return x

	else if("players" in input)
		var/n = 0
		for(var/mob/M in GLOB.player_list)
			if(M.client)
				n++
		return n

	else if("ircstatus" in input)
		if(world.time - last_irc_status < IRC_STATUS_THROTTLE)
			return
		var/list/adm = get_admin_counts()
		var/list/allmins = adm["total"]
		var/status = "Admins: [allmins.len] (Active: [english_list(adm["present"])] AFK: [english_list(adm["afk"])] Stealth: [english_list(adm["stealth"])] Skipped: [english_list(adm["noflags"])]). "
		status += "Players: [GLOB.clients.len] (Active: [get_active_player_count(0,1,0)]). Mode: [SSticker.mode.name]."
		send2irc("Status", status)
		last_irc_status = world.time

	else if("status" in input)
		var/list/s = list()
		s["version"] = GLOB.game_version
		s["mode"] = GLOB.master_mode
		s["respawn"] = config ? GLOB.abandon_allowed : 0
		s["enter"] = GLOB.enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["active_players"] = get_active_player_count()
		s["players"] = GLOB.clients.len
		s["revision"] = GLOB.revdata.commit
		s["revision_date"] = GLOB.revdata.date

		var/list/adm = get_admin_counts()
		var/list/presentmins = adm["present"]
		var/list/afkmins = adm["afk"]
		s["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho


		s["gamestate"] = 1
		if(SSticker)
			s["gamestate"] = SSticker.current_state

		s["map_name"] = SSmapping.config.map_name

		if(key_valid && SSticker.HasRoundStarted())
			s["real_mode"] = SSticker.mode.name
			// Key-authed callers may know the truth behind the "secret"

		s["security_level"] = get_security_level()
		s["round_duration"] = SSticker ? round((world.time-SSticker.round_start_time)/10) : 0
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
			AnnouncePR(input["announce"], json_decode(input["payload"]))

	else if("crossmessage" in input)
		if(!key_valid)
			return
		else
			if(input["crossmessage"] == "Ahelp")
				relay_msg_admins("<span class='adminnotice'><b><font color=red>HELP: </font> [input["source"]] [input["message_sender"]]: [input["message"]]</b></span>")
			if(input["crossmessage"] == "Comms_Console")
				minor_announce(input["message"], "Incoming message from [input["message_sender"]]")
				for(var/obj/machinery/computer/communications/CM in GLOB.machines)
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

#define PR_ANNOUNCEMENTS_PER_ROUND 5 //The number of unique PR announcements allowed per round
									//This makes sure that a single person can only spam 3 reopens and 3 closes before being ignored

/world/proc/AnnouncePR(announcement, list/payload)
	var/static/list/PRcounts = list()	//PR id -> number of times announced this round
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > PR_ANNOUNCEMENTS_PER_ROUND)
			return

#define CHAT_PULLR	64 //defined in preferences.dm, but not available here at compilation time
	for(var/client/C in GLOB.clients)
		if(C.prefs && (C.prefs.chat_toggles & CHAT_PULLR))
			C << "<span class='announce'>PR: [announcement]</span>"
#undef CHAT_PULLR

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
	if(SSticker.delay_end)
		to_chat(world, "<span class='boldannounce'>An admin has delayed the round end.</span>")
		return
	to_chat(world, "<span class='boldannounce'>Rebooting World in [delay/10] [(delay >= 10 && delay < 20) ? "second" : "seconds"]. [reason]</span>")
	var/round_end_sound_sent = FALSE
	if(SSticker.round_end_sound)
		round_end_sound_sent = TRUE
		for(var/thing in GLOB.clients)
			var/client/C = thing
			if (!C)
				continue
			C.Export("##action=load_rsc", SSticker.round_end_sound)
	sleep(delay)
	if(SSticker.delay_end)
		to_chat(world, "<span class='boldannounce'>Reboot was cancelled by an admin.</span>")
		return
	OnReboot(reason, feedback_c, feedback_r, round_end_sound_sent)
	WORLD_REBOOT(0)
#undef WORLD_REBOOT

/world/proc/OnReboot(reason, feedback_c, feedback_r, round_end_sound_sent)
	SSblackbox.set_details("[feedback_c]","[feedback_r]")
	log_game("<span class='boldannounce'>Rebooting World. [reason]</span>")
	SSblackbox.set_val("ahelp_unresolved", GLOB.ahelp_tickets.active_tickets.len)
	Master.Shutdown()	//run SS shutdowns
	RoundEndAnimation(round_end_sound_sent)
	kick_clients_in_lobby("<span class='boldannounce'>The round came to an end with you in the lobby.</span>", 1) //second parameter ensures only afk clients are kicked
	to_chat(world, "<span class='boldannounce'>Rebooting world...</span>")
	for(var/thing in GLOB.clients)
		var/client/C = thing
		if(C && config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

/world/proc/RoundEndAnimation(round_end_sound_sent)
	set waitfor = FALSE
	var/round_end_sound
	if(SSticker.round_end_sound)
		round_end_sound = SSticker.round_end_sound
		if (!round_end_sound_sent)
			for(var/thing in GLOB.clients)
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

	for(var/thing in GLOB.clients)
		var/obj/screen/splash/S = new(thing, FALSE)
		S.Fade(FALSE,FALSE)

	world << sound(round_end_sound)

/world/proc/load_mode()
	var/list/Lines = world.file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			GLOB.master_mode = Lines[1]
			GLOB.world_game_log << "Saved mode is '[GLOB.master_mode]'"

/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_motd()
	GLOB.join_motd = file2text("config/motd.txt") + "<br>" + GLOB.revdata.GetTestMergeInfo()

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

	if(SSticker)
		if(GLOB.master_mode)
			features += GLOB.master_mode
	else
		features += "<b>STARTING</b>"

	if (!GLOB.enter_allowed)
		features += "closed"

	features += GLOB.abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in GLOB.player_list)
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


/world/proc/has_round_started()
	return SSticker.HasRoundStarted()
