#define RESTART_COUNTER_PATH "data/round_counter.txt"

GLOBAL_VAR(restart_counter)

/**
 * World creation
 *
 * Here is where a round itself is actually begun and setup.
 * * db connection setup
 * * config loaded from files
 * * loads admins
 * * Sets up the dynamic menu system
 * * and most importantly, calls initialize on the master subsystem, starting the game loop that causes the rest of the game to begin processing and setting up
 *
 *
 * Nothing happens until something moves. ~Albert Einstein
 *
 * For clarity, this proc gets triggered later in the initialization pipeline, it is not the first thing to happen, as it might seem.
 *
 * Initialization Pipeline:
 * Global vars are new()'ed, (including config, glob, and the master controller will also new and preinit all subsystems when it gets new()ed)
 * Compiled in maps are loaded (mainly centcom). all areas/turfs/objs/mobs(ATOMs) in these maps will be new()ed
 * world/New() (You are here)
 * Once world/New() returns, client's can connect.
 * 1 second sleep
 * Master Controller initialization.
 * Subsystem initialization.
 * Non-compiled-in maps are maploaded, all atoms are new()ed
 * All atoms in both compiled and uncompiled maps are initialized()
 */
/world/New()

	log_world("World loaded at [time_stamp()]!")

	make_datum_references_lists() //initialises global lists for referencing frequently used datums (so that we only ever do it once)

	GLOB.config_error_log = GLOB.world_manifest_log = GLOB.world_pda_log = GLOB.world_job_debug_log = GLOB.sql_error_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = GLOB.world_econ_log = GLOB.world_shuttle_log = "data/logs/config_error.[GUID()].log" //temporary file used to record errors with loading config, moved to log directory once logging is set bl

	GLOB.revdata = new

	InitTgs()

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	load_admins()

	//SetupLogs depends on the RoundID, so lets check
	//DB schema and set RoundID if we can
	SSdbcore.CheckSchemaVersion()
	SSdbcore.SetRoundID()
	SetupLogs()
	load_poll_data()

#ifndef USE_CUSTOM_ERROR_HANDLER
	world.log = file("[GLOB.log_directory]/dd.log")
#else
	if (TgsAvailable())
		world.log = file("[GLOB.log_directory]/dd.log") //not all runtimes trigger world/Error, so this is the only way to ensure we can see all of them.
#endif

	LoadVerbs(/datum/verbs/menu)
	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()

	GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	#ifdef UNIT_TESTS
	HandleTestRun()
	#endif

/world/proc/InitTgs()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	GLOB.revdata.load_tgs_info()

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	CONFIG_SET(number/round_end_countdown, 0)
	var/datum/callback/cb
#ifdef UNIT_TESTS
	cb = CALLBACK(GLOBAL_PROC, /proc/RunUnitTests)
#else
	cb = VARSET_CALLBACK(SSticker, force_ending, TRUE)
#endif
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, /proc/_addtimer, cb, 10 SECONDS))


/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		var/realtime = world.realtime
		var/texttime = time2text(realtime, "YYYY/MM/DD")
		GLOB.log_directory = "data/logs/[texttime]/round-"
		GLOB.picture_logging_prefix = "L_[time2text(realtime, "YYYYMMDD")]_"
		GLOB.picture_log_directory = "data/picture_logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
			GLOB.picture_logging_prefix += "R_[GLOB.round_id]_"
			GLOB.picture_log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(time_stamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
			GLOB.picture_log_directory += "[timestamp]"
			GLOB.picture_logging_prefix += "T_[timestamp]_"
	else
		GLOB.log_directory = "data/logs/[override_dir]"
		GLOB.picture_logging_prefix = "O_[override_dir]_"
		GLOB.picture_log_directory = "data/picture_logs/[override_dir]"

	GLOB.world_game_log = "[GLOB.log_directory]/game.log"
	GLOB.world_silicon_log = "[GLOB.log_directory]/silicon.log"
	GLOB.world_suspicious_login_log = "[GLOB.log_directory]/suspicious_logins.log"
	GLOB.world_mecha_log = "[GLOB.log_directory]/mecha.log"
	GLOB.world_virus_log = "[GLOB.log_directory]/virus.log"
	GLOB.world_cloning_log = "[GLOB.log_directory]/cloning.log"
	GLOB.world_asset_log = "[GLOB.log_directory]/asset.log"
	GLOB.world_attack_log = "[GLOB.log_directory]/attack.log"
	GLOB.world_econ_log = "[GLOB.log_directory]/econ.log"
	GLOB.world_pda_log = "[GLOB.log_directory]/pda.log"
	GLOB.world_uplink_log = "[GLOB.log_directory]/uplink.log"
	GLOB.world_telecomms_log = "[GLOB.log_directory]/telecomms.log"
	GLOB.world_manifest_log = "[GLOB.log_directory]/manifest.log"
	GLOB.world_href_log = "[GLOB.log_directory]/hrefs.log"
	GLOB.world_mob_tag_log = "[GLOB.log_directory]/mob_tags.log"
	GLOB.sql_error_log = "[GLOB.log_directory]/sql.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_map_error_log = "[GLOB.log_directory]/map_errors.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"
	GLOB.query_debug_log = "[GLOB.log_directory]/query_debug.log"
	GLOB.world_job_debug_log = "[GLOB.log_directory]/job_debug.log"
	GLOB.world_paper_log = "[GLOB.log_directory]/paper.log"
	GLOB.tgui_log = "[GLOB.log_directory]/tgui.log"
	GLOB.world_shuttle_log = "[GLOB.log_directory]/shuttle.log"

	GLOB.demo_log = "[GLOB.log_directory]/demo.log"

#ifdef UNIT_TESTS
	GLOB.test_log = "[GLOB.log_directory]/tests.log"
	start_log(GLOB.test_log)
#endif
	start_log(GLOB.world_game_log)
	start_log(GLOB.world_attack_log)
	start_log(GLOB.world_econ_log)
	start_log(GLOB.world_pda_log)
	start_log(GLOB.world_uplink_log)
	start_log(GLOB.world_telecomms_log)
	start_log(GLOB.world_manifest_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.world_mob_tag_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_job_debug_log)
	start_log(GLOB.tgui_log)
	start_log(GLOB.world_shuttle_log)

	var/latest_changelog = file("[global.config.directory]/../html/changelogs/archive/" + time2text(world.timeofday, "YYYY-MM") + ".yml")
	GLOB.changelog_hash = fexists(latest_changelog) ? md5(latest_changelog) : 0 //for telling if the changelog has changed recently
	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	// This was printed early in startup to the world log and config_error.log,
	// but those are both private, so let's put the commit info in the runtime
	// log which is ultimately public.
	log_runtime(GLOB.revdata.get_log_message())

/world/Topic(T, addr, master, key)
	TGS_TOPIC //redirect to server tools if necessary

	var/static/list/topic_handlers = TopicHandlers()

	var/list/input = params2list(T)
	var/datum/world_topic/handler
	for(var/I in topic_handlers)
		if(I in input)
			handler = topic_handlers[I]
			break

	if((!handler || initial(handler.log)) && config && CONFIG_GET(flag/log_world_topic))
		log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if(!handler)
		return

	handler = new handler()
	return handler.TryRun(input)

/world/proc/AnnouncePR(announcement, list/payload)
	var/static/list/PRcounts = list() //PR id -> number of times announced this round
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > PR_ANNOUNCEMENTS_PER_ROUND)
			return

	var/final_composed = span_announce("PR: [announcement]")
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
#ifdef UNIT_TESTS
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
#endif
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		text2file("Success!", "[GLOB.log_directory]/clean_run.lk")
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0) //yes, 0, this'll let Reboot finish and prevent byond memes
	qdel(src) //shut it down

/world/Reboot(reason = 0, fast_track = FALSE)
	if (reason || fast_track) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, span_boldannounce("Rebooting World immediately due to host request."))
	else
		to_chat(world, span_boldannounce("Rebooting world..."))
		Master.Shutdown() //run SS shutdowns

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#endif

	if(TgsAvailable())
		var/do_hard_reboot
		// check the hard reboot counter
		var/ruhr = CONFIG_GET(number/rounds_until_hard_restart)
		switch(ruhr)
			if(-1)
				do_hard_reboot = FALSE
			if(0)
				do_hard_reboot = TRUE
			else
				if(GLOB.restart_counter >= ruhr)
					do_hard_reboot = TRUE
				else
					text2file("[++GLOB.restart_counter]", RESTART_COUNTER_PATH)
					do_hard_reboot = FALSE

		if(do_hard_reboot)
			log_world("World hard rebooted at [time_stamp()]")
			shutdown_logging() // See comment below.
			TgsEndProcess()

	log_world("World rebooted at [time_stamp()]")

	TgsReboot()
	shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.
	..()

/world/proc/update_status()

	var/list/features = list()

	if(LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS))
		features += "closed"

	var/s = ""
	var/hostedby
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		if (server_name)
			s += "<b>[server_name]</b> &#8212; "
		features += "[CONFIG_GET(flag/norespawn) ? "no " : ""]respawn"
		if(CONFIG_GET(flag/allow_ai))
			features += "AI allowed"
		hostedby = CONFIG_GET(string/hostedby)

	s += "<b>[station_name()]</b>";
	s += " ("
	s += "<a href=\"http://\">" //Change this to wherever you want the hub to link to.
	s += "Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += ")"

	var/players = GLOB.clients.len

	var/popcaptext = ""
	var/popcap = max(CONFIG_GET(number/extreme_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/soft_popcap))
	if (popcap)
		popcaptext = "/[popcap]"

	if (players > 1)
		features += "[players][popcaptext] players"
	else if (players > 0)
		features += "[players][popcaptext] player"

	game_state = (CONFIG_GET(number/extreme_popcap) && players >= CONFIG_GET(number/extreme_popcap)) //tells the hub if we are full

	if (!host && hostedby)
		features += "hosted by <b>[hostedby]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

	status = s

/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == GLOB.hub_visibility)
		return
	GLOB.hub_visibility = new_visibility
	if(GLOB.hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"

/world/proc/incrementMaxZ()
	maxz++
	SSmobs.MaxZChanged()
	SSidlenpcpool.MaxZChanged()


/world/proc/change_fps(new_value = 20)
	if(new_value <= 0)
		CRASH("change_fps() called with [new_value] new_value.")
	if(fps == new_value)
		return //No change required.

	fps = new_value
	on_tickrate_change()


/world/proc/change_tick_lag(new_value = 0.5)
	if(new_value <= 0)
		CRASH("change_tick_lag() called with [new_value] new_value.")
	if(tick_lag == new_value)
		return //No change required.

	tick_lag = new_value
	on_tickrate_change()


/world/proc/on_tickrate_change()
	SStimer?.reset_buckets()
