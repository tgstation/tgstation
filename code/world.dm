/world
	mob = /mob/new_player
<<<<<<< HEAD
	turf = /turf/open/space
	area = /area/space
	view = "15x15"
	cache_lifespan = 7
	fps = 20

var/global/list/map_transition_config = MAP_TRANSITION_CONFIG

/world/New()
	check_for_cleanbot_bug()
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

=======
	turf = /turf/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session
	//loop_checks = 0
#define RECOMMENDED_VERSION 510


var/savefile/panicfile
/world/New()
	//populate_seed_list()
	plant_controller = new()

	// Honk honk, fuck you science
	for(var/i=1, i<=map.zLevels.len, i++)
		WORLD_X_OFFSET += rand(-50,50)
		WORLD_Y_OFFSET += rand(-50,50)

	// Initialize world events as early as possible.
	on_login = new ()
	on_ban   = new ()
	on_unban = new ()


	/*Runtimes, not sure if i need it still so commenting out for now
	starticon = rotate_icon('icons/obj/lightning.dmi', "lightningstart")
	midicon = rotate_icon('icons/obj/lightning.dmi', "lightning")
	endicon = rotate_icon('icons/obj/lightning.dmi', "lightningend")
	*/

	// logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")

	investigations[I_HREFS] = new /datum/log_controller(I_HREFS, filename="data/logs/[date_string] hrefs.htm", persist=TRUE)
	investigations[I_ATMOS] = new /datum/log_controller(I_ATMOS, filename="data/logs/[date_string] atmos.htm", persist=TRUE)
	investigations[I_CHEMS] = new /datum/log_controller(I_CHEMS, filename="data/logs/[date_string] chemistry.htm", persist=TRUE)
	investigations[I_WIRES] = new /datum/log_controller(I_WIRES, filename="data/logs/[date_string] wires.htm", persist=TRUE)

	diary = file("data/logs/[date_string].log")
	panicfile = new/savefile("data/logs/profiling/proclogs/[date_string].sav")
	diaryofmeanpeople = file("data/logs/[date_string] Attack.log")
	admin_diary = file("data/logs/[date_string] admin only.log")

	var/log_start = "---------------------\n\[[time_stamp()]\]WORLD: starting up..."

	diary << log_start
	diaryofmeanpeople << log_start
	admin_diary << log_start
	var/ourround = time_stamp()
	panicfile.cd = ourround


	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently
/*
 * IF YOU HAVE BYOND VERSION BELOW 507.1248 OR ARE ABLE TO WALK THROUGH WINDOORS/BORDER WINDOWS COMMENT OUT
 * #define BORDER_USE_TURF_EXIT
 * FOR MORE INFORMATION SEE: http://www.byond.com/forum/?post=1666940
 */
#ifdef BORDER_USE_TURF_EXIT
	if(byond_version < 510)
		warning("Your server's byond version does not meet the recommended requirements for this code. Please update BYOND to atleast 507.1248 or comment BORDER_USE_TURF_EXIT in global.dm")
#elif
	if(byond_version < RECOMMENDED_VERSION)
		world.log << "Your server's byond version does not meet the recommended requirements for this code. Please update BYOND"
#endif
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)

	load_configuration()
	load_mode()
	load_motd()
	load_admins()
<<<<<<< HEAD
	if(config.usewhitelist)
		load_whitelist()
	appearance_loadbanfile()
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

	spawn(10)
		Master.Setup()

	process_teleport_locs()			//Sets up the wizard teleport locations
	SortAreas()						//Build the list of all existing areas and sort it alphabetically

	#ifdef MAP_NAME
	map_name = "[MAP_NAME]"
	#else
	map_name = "Unknown"
	#endif


	return

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
=======
	load_mods()
	LoadBansjob()
	if(config.usewhitelist)
		load_whitelist()
	if(config.usealienwhitelist)
		load_alienwhitelist()
	jobban_loadbanfile()
	jobban_updatelegacybans()
	appearance_loadbanfile()
	LoadBans()
	SetupHooks() // /vg/

	library_catalog.initialize()

	spawn() copy_logs() // Just copy the logs.
	if(config && config.log_runtimes)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD")]-runtime.log")
	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	Get_Holiday()	//~Carn, needs to be here when the station is named so :P

	src.update_status()

	paperwork_setup()

	//sun = new /datum/sun()
	radio_controller = new /datum/controller/radio()
	data_core = new /obj/effect/datacore()
	paiController = new /datum/paiController()

	if(!setup_database_connection())
		world.log << "Your server failed to establish a connection with the feedback database."
	else
		world.log << "Feedback database connection established."
	migration_controller_mysql = new
	migration_controller_sqlite = new ("players2.sqlite", "players2_empty.sqlite")

	if(!setup_old_database_connection())
		world.log << "Your server failed to establish a connection with the tgstation database."
	else
		world.log << "Tgstation database connection established."

	plmaster = new /obj/effect/overlay()
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = FLY_LAYER
	plmaster.plane = PLANE_EFFECTS
	plmaster.mouse_opacity = 0

	slmaster = new /obj/effect/overlay()
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = FLY_LAYER
	slmaster.plane = PLANE_EFFECTS
	slmaster.mouse_opacity = 0

	src.update_status()

	sleep_offline = 1

	send2mainirc("Server starting up on [config.server? "byond://[config.server]" : "byond://[world.address]:[world.port]"]")

	processScheduler = new
	master_controller = new /datum/controller/game_controller()

	spawn(1)
		turfs = new/list(maxx*maxy*maxz)
		world.log << "DEBUG: TURFS LIST LENGTH [turfs.len]"
		build_turfs_list()

		processScheduler.deferSetupFor(/datum/controller/process/ticker)
		processScheduler.setup()

		master_controller.setup()

		setup_species()
		setup_shuttles()

		stat_collection.artifacts_discovered = 0 // Because artifacts during generation get counted otherwise!

	for(var/plugin_type in typesof(/plugin))
		var/plugin/P = new plugin_type()
		plugins[P.name] = P
		P.on_world_loaded()

	process_teleport_locs()				//Sets up the wizard teleport locations
	process_ghost_teleport_locs()		//Sets up ghost teleport locations.
	process_adminbus_teleport_locs()	//Sets up adminbus teleport locations.
	SortAreas()							//Build the list of all existing areas and sort it alphabetically

	spawn(2000)		//so we aren't adding to the round-start lag
		if(config.ToRban)
			ToRban_autoupdate()
		/*if(config.kick_inactive)
			KickInactiveClients()*/

#undef RECOMMENDED_VERSION

	return ..()

//world/Topic(href, href_list[])
//		to_chat(world, "Received a Topic() call!")
//		to_chat(world, "[href]")
//		for(var/a in href_list)
//			to_chat(world, "[a]")
//		if(href_list["hello"])
//			to_chat(world, "Hello world!")
//			return "Hello world!"
//		to_chat(world, "End of Topic() call.")
//		..()

/world/Topic(T, addr, master, key)
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]"

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

<<<<<<< HEAD
	else if("ircstatus" in input)
		if(world.time - last_irc_status < IRC_STATUS_THROTTLE)
			return
		var/list/adm = get_admin_counts()
		var/status = "Admins: [Sum(adm)] (Active: [adm["admins"]] AFK: [adm["afkadmins"]] Stealth: [adm["stealthadmins"]] Skipped: [adm["noflagadmins"]]). "
		status += "Players: [clients.len] (Active: [get_active_player_count()]). Mode: [master_mode]."
		send2irc("Status", status)
		last_irc_status = world.time

	else if("status" in input)
=======
	else if (T == "status")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
<<<<<<< HEAD
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
		s["round_duration"] = round(world.time/10)
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

	else if("adminmsg" in input)
		if(!key_valid)
			return "Bad Key"
		else
			return IrcPm(input["adminmsg"],input["msg"],input["sender"])



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
	sleep(delay)
	if(blackbox)
		blackbox.save_all_data_to_sql()
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
	spawn(0)
		if(ticker && ticker.round_end_sound)
			world << sound(ticker.round_end_sound)
		else
			world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg','sound/misc/leavingtg.ogg')) // random end sounds!! - LastyBatsy
	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")
	..(0)

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
=======
		s["players"] = list()
		s["map_name"] = map.nameLong
		s["gamestate"] = 1
		if(ticker)
			s["gamestate"] = ticker.current_state
		s["active_players"] = get_active_player_count()
		s["revision"] = return_revision()
		var/n = 0
		var/admins = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++
		s["players"] = n

		if(revdata)	s["revision"] = revdata.revision
		s["admins"] = admins

		return list2params(s)
	else if (findtext(T,"notes:"))
		var/notekey = copytext(T, 7)
		return list2params(exportnotes(notekey))


/world/Reboot(reason)
	if(reason == 1)
		if(usr && usr.client)
			if(!usr.client.holder)
				return 0
	if(config.map_voting)
		//testing("we have done a map vote")
		if(fexists(vote.chosen_map))
			//testing("[vote.chosen_map] exists")
			var/start = 1
			var/pos = findtext(vote.chosen_map, "/", start)
			var/lastpos = pos
			//testing("First slash [lastpos]")
			while(pos > 0)
				lastpos = pos
				pos = findtext(vote.chosen_map, "/", start)
				start = pos + 1
				//testing("Next slash [pos]")
			var/filename = copytext(vote.chosen_map, lastpos + 1, 0)
			//testing("Found [filename]")

			if(!fcopy(vote.chosen_map, filename))
				//testing("Fcopy failed, deleting and copying")
				fdel(filename)
				fcopy(vote.chosen_map, filename)
			sleep(60)

	processScheduler.stop()
	paperwork_stop()

	spawn()
		world << sound(pick(
			'sound/AI/newroundsexy.ogg',
			'sound/misc/RoundEndSounds/apcdestroyed.ogg',
			'sound/misc/RoundEndSounds/bangindonk.ogg',
			'sound/misc/RoundEndSounds/slugmissioncomplete.ogg',
			'sound/misc/RoundEndSounds/bayojingle.ogg',
			'sound/misc/RoundEndSounds/gameoveryeah.ogg',
			'sound/misc/RoundEndSounds/rayman.ogg',
			'sound/misc/RoundEndSounds/marioworld.ogg',
			'sound/misc/RoundEndSounds/soniclevelcomplete.ogg',
			'sound/misc/RoundEndSounds/calamitytrigger.ogg',
			'sound/misc/RoundEndSounds/duckgame.ogg',
			'sound/misc/RoundEndSounds/FTLvictory.ogg',
			'sound/misc/RoundEndSounds/tfvictory.ogg',
			'sound/misc/RoundEndSounds/megamanX.ogg',
			'sound/misc/RoundEndSounds/castlevania.ogg',
			)) // random end sounds!! - LastyBatsy

	sleep(5)//should fix the issue of players not hearing the restart sound.

	for(var/client/C in clients)
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

		else
			C << link("byond://[world.address]:[world.port]")


	..()


#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	spawn(-1)
		//set background = 1
		while(1)
			sleep(INACTIVITY_KICK)
			for(var/client/C in clients)
				if(C.is_afk(INACTIVITY_KICK))
					if(!istype(C.mob, /mob/dead))
						log_access("AFK: [key_name(C)]")
						to_chat(C, "<span class='warning'>You have been inactive for more than 10 minutes and have been disconnected.</span>")
						del(C)
//#undef INACTIVITY_KICK

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			diary << "Saved mode is '[master_mode]'"

<<<<<<< HEAD
/world/proc/save_mode(the_mode)
=======
/world/proc/save_mode(var/the_mode)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")

/world/proc/load_configuration()
<<<<<<< HEAD
	protected_config = new /datum/protected_configuration()
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
<<<<<<< HEAD
	if (config.maprotation && SERVERTOOLS)
		config.loadmaplist("config/maps.txt")

	// apply some settings from config..
	abandon_allowed = config.respawn

=======
	config.loadforumsql("config/forumdbconfig.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn

/world/proc/load_mods()
	if(config.admin_legacy_system)
		var/text = file2text("config/moderators.txt")
		if (!text)
			diary << "Failed to load config/mods.txt\n"
		else
			var/list/lines = splittext(text, "\n")
			for(var/line in lines)
				if (!line)
					continue

				if (copytext(line, 1, 2) == ";")
					continue

				var/rights = admin_ranks["Moderator"]
				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins("Moderator", rights, ckey)
				D.associate(directory[ckey])
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "

<<<<<<< HEAD
	s += "<b>[station_name()]</b>";
	s += " ("
	s += "<a href=\"http://\">" //Change this to wherever you want the hub to link to.
//	s += "[game_version]"
	s += "Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += ")"

=======

	s += {"<b>[station_name()]</b>"
		(
		<a href=\"http://\">" //Change this to wherever you want the hub to link to
		Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version
		</a>
		)"}
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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

<<<<<<< HEAD
=======
	/*
	is there a reason for this? the byond site shows 'hosted by X' when there is a proper host already.
	if (host)
		features += "hosted by <b>[host]</b>"
	*/

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if (!host && config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

<<<<<<< HEAD
	status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0

/proc/setup_database_connection()

	if(failed_db_connections >= FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
=======
	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

proc/setup_database_connection()


	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
		failed_db_connections++		//If it failed, increase the failed connections counter.
		if(config.sql_enabled)
			world.log << "SQL error: " + dbcon.ErrorMsg()
=======
		world.log << "Database Error: [dbcon.ErrorMsg()]"
		failed_db_connections++		//If it failed, increase the failed connections counter.
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
<<<<<<< HEAD
/proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

=======
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	var/DBQuery/q
	if(dbcon)
		q = dbcon.NewQuery("show global variables like 'wait_timeout'")
		q.Execute()
		if(q && q.ErrorMsg())
			dbcon.Disconnect()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

<<<<<<< HEAD
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
=======



//These two procs are for the old database, while it's being phased out. See the tgstation.sql file in the SQL folder for more information.
proc/setup_old_database_connection()


	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon_old)
		dbcon_old = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon_old.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon_old.IsConnected()
	if ( . )
		failed_old_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_old_db_connections++		//If it failed, increase the failed connections counter.
		world.log << dbcon_old.ErrorMsg()

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_old_db_connection()
	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_old || !dbcon_old.IsConnected())
		return setup_old_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF
/world/proc/build_turfs_list()
	var/count = 0
	for(var/Z = 1 to world.maxz)
		for(var/turf/T in block(locate(1,1,Z), locate(world.maxx, world.maxy, Z)))
			if(!(count % 50000)) sleep(world.tick_lag)
			count++
			T.initialize()
			turfs[count] = T
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
