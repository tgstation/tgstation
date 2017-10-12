GLOBAL_VAR(security_mode)
GLOBAL_PROTECT(security_mode)

/world/New()
	log_world("World loaded at [time_stamp()]")

	SetupExternalRSC()

	GLOB.config_error_log = GLOB.world_pda_log = GLOB.sql_error_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = file("data/logs/config_error.log") //temporary file used to record errors with loading config, moved to log directory once logging is set bl

	CheckSecurityMode()

	make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)

	new /datum/controller/configuration

	hippie_initialize()
	CheckSchemaVersion()
	SetRoundID()

	SetupLogs()

	SERVER_TOOLS_ON_NEW

	load_motd()
	load_admins()
	LoadVerbs(/datum/verbs/menu)
	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()
	LoadBans()

	GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	Master.Initialize(10, FALSE)

/world/proc/SetupExternalRSC()
#if (PRELOAD_RSC == 0)
	external_rsc_urls = world.file2list("config/external_rsc_urls.txt","\n")
	var/i=1
	while(i<=external_rsc_urls.len)
		if(external_rsc_urls[i])
			i++
		else
			external_rsc_urls.Cut(i,i+1)
#endif

/world/proc/CheckSchemaVersion()
	if(CONFIG_GET(flag/sql_enabled))
		if(SSdbcore.Connect())
			log_world("Database connection established.")
			var/datum/DBQuery/query_db_version = SSdbcore.NewQuery("SELECT major, minor FROM [format_table_name("schema_revision")] ORDER BY date DESC LIMIT 1")
			query_db_version.Execute()
			if(query_db_version.NextRow())
				var/db_major = text2num(query_db_version.item[1])
				var/db_minor = text2num(query_db_version.item[2])
				if(db_major != DB_MAJOR_VERSION || db_minor != DB_MINOR_VERSION)
					var/which = "behind"
					if(db_major < DB_MAJOR_VERSION || db_minor < DB_MINOR_VERSION)
						which = "ahead of"
					message_admins("Database schema ([db_major].[db_minor]) is [which] the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
					log_sql("Database schema ([db_major].[db_minor]) is [which] the latest schema version ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]), this may lead to undefined behaviour or errors")
			else
				message_admins("Could not get schema version from database")
		else
			log_world("Your server failed to establish a connection with the database.")

/world/proc/SetRoundID()
	var/internet_address_to_use = CONFIG_GET(string/internet_address_to_use)
	if(CONFIG_GET(flag/sql_enabled))
		if(SSdbcore.Connect())
			var/datum/DBQuery/query_round_start = SSdbcore.NewQuery("INSERT INTO [format_table_name("round")] (start_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF('[internet_address_to_use]' LIKE '', '0', '[internet_address_to_use]')), '[world.port]')")
			query_round_start.Execute()
			var/datum/DBQuery/query_round_last_id = SSdbcore.NewQuery("SELECT LAST_INSERT_ID()")
			query_round_last_id.Execute()
			if(query_round_last_id.NextRow())
				GLOB.round_id = query_round_last_id.item[1]

/world/proc/SetupLogs()
	GLOB.log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM/DD")]/round-"
	if(GLOB.round_id)
		GLOB.log_directory += "[GLOB.round_id]"
	else
		GLOB.log_directory += "[replacetext(time_stamp(), ":", ".")]"
	GLOB.world_game_log = file("[GLOB.log_directory]/game.log")
	GLOB.world_attack_log = file("[GLOB.log_directory]/attack.log")
	GLOB.world_runtime_log = file("[GLOB.log_directory]/runtime.log")
	GLOB.world_qdel_log = file("[GLOB.log_directory]/qdel.log")
	GLOB.world_href_log = file("[GLOB.log_directory]/hrefs.html")
	GLOB.world_pda_log = file("[GLOB.log_directory]/pda.log")
	GLOB.sql_error_log = file("[GLOB.log_directory]/sql.log")
	WRITE_FILE(GLOB.world_game_log, "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------")
	WRITE_FILE(GLOB.world_attack_log, "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------")
	WRITE_FILE(GLOB.world_runtime_log, "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------")
	WRITE_FILE(GLOB.world_pda_log, "\n\nStarting up round ID [GLOB.round_id]. [time_stamp()]\n---------------------")
	GLOB.changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently
	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

/world/proc/CheckSecurityMode()
	//try to write to data
	if(!text2file("The world is running at least safe mode", "data/server_security_check.lock"))
		GLOB.security_mode = SECURITY_ULTRASAFE
		warning("/tg/station 13 is not supported in ultrasafe security mode. Everything will break!")
		return

	//try to shell
	if(shell("echo \"The world is running in trusted mode\"") != null)
		GLOB.security_mode = SECURITY_TRUSTED
	else
		GLOB.security_mode = SECURITY_SAFE
		warning("/tg/station 13 uses many file operations, a few shell()s, and some external call()s. Trusted mode is recommended. You can download our source code for your own browsing and compilation at https://github.com/tgstation/tgstation")

/world/Topic(T, addr, master, key)
	var/static/list/topic_handlers = TopicHandlers()

	var/list/input = params2list(T)
	var/datum/world_topic/handler
	for(var/I in topic_handlers)
		if(input[I])
			handler = topic_handlers[I]
			break
	
	if((!handler || initial(handler.log)) && config && CONFIG_GET(flag/log_world_topic))
		WRITE_FILE(GLOB.world_game_log, "TOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

	SERVER_TOOLS_ON_TOPIC	//redirect to server tools if necessary

	if(!handler)
		return

	handler = new handler()
	return handler.TryRun(input)

/world/proc/AnnouncePR(announcement, list/payload)
	var/static/list/PRcounts = list()	//PR id -> number of times announced this round
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > PR_ANNOUNCEMENTS_PER_ROUND)
			return

	var/final_composed = "<span class='announce'>PR: [announcement]</span>"
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/world/Reboot(reason = 0, fast_track = FALSE)
	SERVER_TOOLS_ON_REBOOT
	if (reason || fast_track) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
		to_chat(world, "<span class='boldannounce'>Rebooting World immediately due to host request</span>")
	else
		to_chat(world, "<span class='boldannounce'>Rebooting world...</span>")
		Master.Shutdown()	//run SS shutdowns
	log_world("World rebooted at [time_stamp()]")
	..()

/world/proc/load_motd()
	GLOB.join_motd = file2text("config/motd.txt") + "<br>" + GLOB.revdata.GetTestMergeInfo()

/world/proc/update_status()
	var/s = ""
	var/hostedby
	var/forumurl
	var/githuburl
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		hostedby = CONFIG_GET(string/hostedby)
		forumurl = CONFIG_GET(string/forumurl)
		githuburl = CONFIG_GET(string/githuburl)
		if (server_name)
			s += "<a href=\"[forumurl]\"><big><b>[server_name]</b> &#8212; [station_name()]</big></a>"
	if(SSticker)
		if(GLOB.master_mode)
			s += "<br>Mode: <b>[GLOB.master_mode]</b>"
	else
		s += "<br>Mode: <b>STARTING</b>"
	if (hostedby)
		s += "<br>Hosted by <b>[hostedby]</b>."
	s += "<img src=\"https://i.imgur.com/xfWVypg.png\">" //Banner image
	s += "<br>("
	s += "<a href=\"[githuburl]\">"
	s += "Github"
	s += "</a>"
	s += ") "

	status = s

/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == GLOB.hub_visibility)
		return
	GLOB.hub_visibility = new_visibility
	if(GLOB.hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"
