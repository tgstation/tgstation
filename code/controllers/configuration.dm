//Configuraton defines //TODO: Move all yes/no switches into bitflags

//Used by jobs_have_maint_access
#define ASSISTANTS_HAVE_MAINT_ACCESS 1
#define SECURITY_HAS_MAINT_ACCESS 2
#define EVERYONE_HAS_MAINT_ACCESS 4

GLOBAL_VAR_INIT(config_dir, "config/")
GLOBAL_PROTECT(config_dir)

/datum/configuration/can_vv_get(var_name)
	var/static/list/banned_gets = list("autoadmin", "autoadmin_rank")
	if (var_name in banned_gets)
		return FALSE
	return ..()

/datum/configuration/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("cross_address", "cross_allowed", "autoadmin", "autoadmin_rank", "invoke_youtubedl")
	if(var_name in banned_edits)
		return FALSE
	return ..()

/datum/configuration
	var/name = "Configuration"			// datum name

	var/autoadmin = 0
	var/autoadmin_rank = "Game Admin"

	var/server_name = null				// server name (the name of the game window)
	var/server_sql_name = null			// short form server name used for the DB
	var/station_name = null				// station name (the name of the station in-game)
	var/lobby_countdown = 120			// In between round countdown.
	var/round_end_countdown = 25		// Post round murder death kill countdown
	var/hub = 0

	var/log_ooc = 0						// log OOC channel
	var/log_access = 0					// log login/logout
	var/log_say = 0						// log client say
	var/log_admin = 0					// log admin actions
	var/log_game = 0					// log game events
	var/log_vote = 0					// log voting
	var/log_whisper = 0					// log client whisper
	var/log_prayer = 0					// log prayers
	var/log_law = 0						// log lawchanges
	var/log_emote = 0					// log emotes
	var/log_attack = 0					// log attack messages
	var/log_adminchat = 0				// log admin chat messages
	var/log_pda = 0						// log pda messages
	var/log_twitter = 0					// log certain expliotable parrots and other such fun things in a JSON file of twitter valid phrases.
	var/log_world_topic = 0				// log all world.Topic() calls
	var/sql_enabled = 0					// for sql switching
	var/allow_admin_ooccolor = 0		// Allows admins with relevant permissions to have their own ooc colour
	var/allow_vote_restart = 0 			// allow votes to restart
	var/allow_vote_mode = 0				// allow votes to change mode
	var/vote_delay = 6000				// minimum time between voting sessions (deciseconds, 10 minute default)
	var/vote_period = 600				// length of voting period (deciseconds, default 1 minute)
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)
	var/del_new_on_log = 1				// del's new players if they log before they spawn in
	var/allow_Metadata = 0				// Metadata is supported.
	var/popup_admin_pm = 0				//adminPMs to non-admins show in a pop-up 'reply' window when set to 1.
	var/fps = 20
	var/allow_holidays = 0				//toggles whether holiday-specific content should be used
	var/tick_limit_mc_init = TICK_LIMIT_MC_INIT_DEFAULT	//SSinitialization throttling

	var/hostedby = null
	var/respawn = 1
	var/guest_jobban = 1
	var/usewhitelist = 0
	var/inactivity_period = 3000		//time in ds until a player is considered inactive
	var/afk_period = 6000				//time in ds until a player is considered afk and kickable
	var/kick_inactive = FALSE			//force disconnect for inactive players
	var/load_jobs_from_txt = 0
	var/automute_on = 0					//enables automuting/spam prevention
	var/minimal_access_threshold = 0	//If the number of players is larger than this threshold, minimal access will be turned on.
	var/jobs_have_minimal_access = 0	//determines whether jobs use minimal access or expanded access.
	var/jobs_have_maint_access = 0 		//Who gets maint access?  See defines above.
	var/sec_start_brig = 0				//makes sec start in brig or dept sec posts

	var/server
	var/banappeals
	var/wikiurl = "http://www.tgstation13.org/wiki" // Default wiki link.
	var/forumurl = "http://tgstation13.org/phpBB/index.php" //default forums
	var/rulesurl = "http://www.tgstation13.org/wiki/Rules" // default rules
	var/githuburl = "https://www.github.com/tgstation/-tg-station" //default github
	var/githubrepoid

	var/forbid_singulo_possession = 0
	var/useircbot = 0

	var/check_randomizer = 0

	var/panic_server_name
	var/panic_address //Reconnect a player this linked server if this server isn't accepting new players

	var/invoke_youtubedl

	//IP Intel vars
	var/ipintel_email
	var/ipintel_rating_bad = 1
	var/ipintel_save_good = 12
	var/ipintel_save_bad = 1
	var/ipintel_domain = "check.getipintel.net"

	var/admin_legacy_system = 0	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
	var/use_age_restriction_for_jobs = 0 //Do jobs use account age restrictions? --requires database
	var/use_account_age_for_jobs = 0	//Uses the time they made the account for the job restriction stuff. New player joining alerts should be unaffected.
	var/see_own_notes = 0 //Can players see their own admin notes (read-only)? Config option in config.txt
	var/note_fresh_days
	var/note_stale_days

	var/use_exp_tracking = FALSE
	var/use_exp_restrictions_heads = FALSE
	var/use_exp_restrictions_heads_hours = 0
	var/use_exp_restrictions_heads_department = FALSE
	var/use_exp_restrictions_other = FALSE
	var/use_exp_restrictions_admin_bypass = FALSE

	//Population cap vars
	var/soft_popcap				= 0
	var/hard_popcap				= 0
	var/extreme_popcap			= 0
	var/soft_popcap_message		= "Be warned that the server is currently serving a high number of users, consider using alternative game servers."
	var/hard_popcap_message		= "The server is currently serving a high number of users, You cannot currently join. You may wait for the number of living crew to decline, observe, or find alternative servers."
	var/extreme_popcap_message	= "The server is currently serving a high number of users, find alternative servers."

	//game_options.txt configs
	var/force_random_names = 0
	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/list/min_pop = list()			// overrides for acceptible player counts in a mode
	var/list/max_pop = list()

	var/humans_need_surnames = 0
	var/allow_ai = 0					// allow ai job
	var/forbid_secborg = 0				// disallow secborg module to be chosen.
	var/forbid_peaceborg = 0
	var/panic_bunker = 0				// prevents new people it hasn't seen before from connecting
	var/notify_new_player_age = 0		// how long do we notify admins of a new player
	var/notify_new_player_account_age = 0		// how long do we notify admins of a new byond account
	var/irc_first_connection_alert = 0	// do we notify the irc channel when somebody is connecting for the first time?

	var/traitor_scaling_coeff = 6		//how much does the amount of players get divided by to determine traitors
	var/changeling_scaling_coeff = 6	//how much does the amount of players get divided by to determine changelings
	var/security_scaling_coeff = 8		//how much does the amount of players get divided by to determine open security officer positions
	var/abductor_scaling_coeff = 15 	//how many players per abductor team

	var/traitor_objectives_amount = 2
	var/protect_roles_from_antagonist = 0 //If security and such can be traitor/cult/other
	var/protect_assistant_from_antagonist = 0 //If assistants can be traitor/cult/other
	var/enforce_human_authority = 0		//If non-human species are barred from joining as a head of staff
	var/allow_latejoin_antagonists = 0 	// If late-joining players can be traitor/changeling
	var/list/continuous = list()		// which roundtypes continue if all antagonists die
	var/list/midround_antag = list() 	// which roundtypes use the midround antagonist system
	var/midround_antag_time_check = 60  // How late (in minutes) you want the midround antag system to stay on, setting this to 0 will disable the system
	var/midround_antag_life_check = 0.7 // A ratio of how many people need to be alive in order for the round not to immediately end in midround antagonist
	var/shuttle_refuel_delay = 12000
	var/show_game_type_odds = 0			//if set this allows players to see the odds of each roundtype on the get revision screen
	var/mutant_races = 0				//players can choose their mutant race before joining the game
	var/list/roundstart_races = list()	//races you can play as from the get go. If left undefined the game's roundstart var for species is used
	var/mutant_humans = 0				//players can pick mutant bodyparts for humans before joining the game

	var/no_summon_guns		//No
	var/no_summon_magic		//Fun
	var/no_summon_events	//Allowed

	var/intercept = 1					//Whether or not to send a communications intercept report roundstart. This may be overriden by gamemodes.
	var/alert_desc_green = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/alert_desc_blue_upto = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."
	var/alert_desc_blue_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	var/alert_desc_red_upto = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	var/alert_desc_red_downto = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	var/alert_desc_delta = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

	var/revival_pod_plants = FALSE
	var/revival_cloning = FALSE
	var/revival_brain_life = -1

	var/rename_cyborg = 0
	var/ooc_during_round = 0
	var/emojis = 0
	var/no_credits_round_end = FALSE

	//Used for modifying movement speed for mobs.
	//Unversal modifiers
	var/run_speed = 0
	var/walk_speed = 0

	//Mob specific modifiers. NOTE: These will affect different mob types in different ways
	var/human_delay = 0
	var/robot_delay = 0
	var/monkey_delay = 0
	var/alien_delay = 0
	var/slime_delay = 0
	var/animal_delay = 0

	var/gateway_delay = 18000 //How long the gateway takes before it activates. Default is half an hour.
	var/ghost_interaction = 0

	var/silent_ai = 0
	var/silent_borg = 0

	var/damage_multiplier = 1 //Modifier for damage to all mobs. Impacts healing as well.

	var/allowwebclient = 0
	var/webclientmembersonly = 0

	var/sandbox_autoclose = FALSE // close the sandbox panel after spawning an item, potentially reducing griff

	var/default_laws = 0 //Controls what laws the AI spawns with.
	var/silicon_max_law_amount = 12
	var/list/lawids = list()

	var/list/law_weights = list()

	var/assistant_cap = -1

	var/starlight = 0
	var/generate_minimaps = 0
	var/grey_assistants = 0

	var/id_console_jobslot_delay = 30

	var/lavaland_budget = 60
	var/space_budget = 16

	var/aggressive_changelog = 0

	var/reactionary_explosions = 0 //If we use reactionary explosions, explosions that react to walls and doors

	var/autoconvert_notes = 0 //if all connecting player's notes should attempt to be converted to the database

	var/announce_admin_logout = 0
	var/announce_admin_login = 0

	var/list/datum/map_config/maplist = list()
	var/datum/map_config/defaultmap = null
	var/maprotation = 1
	var/maprotatechancedelta = 0.75
	var/allow_map_voting = TRUE

	// Enables random events mid-round when set to 1
	var/allow_random_events = 0

	// Multipliers for random events minimal starting time and minimal players amounts
	var/events_min_time_mul = 1
	var/events_min_players_mul = 1

	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick

	var/client_warn_version = 0
	var/client_warn_message = "Your version of byond may have issues or be blocked from accessing this server in the future."
	var/client_error_version = 0
	var/client_error_message = "Your version of byond is too old, may have issues, and is blocked from accessing this server."

	var/cross_name = "Other server"
	var/cross_address = "byond://"
	var/cross_allowed = FALSE
	var/showircname = 0

	var/list/gamemode_cache = null

	var/minutetopiclimit
	var/secondtopiclimit

	var/error_cooldown = 600 // The "cooldown" time for each occurrence of a unique error
	var/error_limit = 50 // How many occurrences before the next will silence them
	var/error_silence_time = 6000 // How long a unique error will be silenced for
	var/error_msg_delay = 50 // How long to wait between messaging admins about occurrences of a unique error

	var/arrivals_shuttle_dock_window = 55	//Time from when a player late joins on the arrivals shuttle to when the shuttle docks on the station
	var/arrivals_shuttle_require_safe_latejoin = FALSE	//Require the arrivals shuttle to be operational in order for latejoiners to join

	var/mice_roundstart = 10 // how many wire chewing rodents spawn at roundstart.

	var/irc_announce_new_game = FALSE

	var/list/policies = list()

	var/debug_admin_hrefs = FALSE	//turns off admin href token protection for debugging purposes

/datum/configuration/New()
	gamemode_cache = typecacheof(/datum/game_mode,TRUE)
	for(var/T in gamemode_cache)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if(M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				WRITE_FILE(GLOB.config_error_log, "Adding game mode [M.name] ([M.config_tag]) to configuration.")
				modes += M.config_tag
				mode_names[M.config_tag] = M.name
				probabilities[M.config_tag] = M.probability
				if(M.votable)
					votable_modes += M.config_tag
		qdel(M)
	votable_modes += "secret"

	Reload()

/datum/configuration/proc/Reload()
	load("config.txt")
	load("comms.txt", "comms")
	load("game_options.txt","game_options")
	load("policies.txt", "policies")
	loadsql("dbconfig.txt")
	if (maprotation)
		loadmaplist("maps.txt")

	// apply some settings from config..
	GLOB.abandon_allowed = respawn

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	filename = "[GLOB.config_dir][filename]"
	var/list/Lines = world.file2list(filename)
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if(!name)
			continue

		if(type == "config")
			switch(name)
				if("hub")
					hub = 1
				if("admin_legacy_system")
					admin_legacy_system = 1
				if("ban_legacy_system")
					ban_legacy_system = 1
				if("use_age_restriction_for_jobs")
					use_age_restriction_for_jobs = 1
				if("use_account_age_for_jobs")
					use_account_age_for_jobs = 1
				if("use_exp_tracking")
					use_exp_tracking = TRUE
				if("use_exp_restrictions_heads")
					use_exp_restrictions_heads = TRUE
				if("use_exp_restrictions_heads_hours")
					use_exp_restrictions_heads_hours = text2num(value)
				if("use_exp_restrictions_heads_department")
					use_exp_restrictions_heads_department = TRUE
				if("use_exp_restrictions_other")
					use_exp_restrictions_other = TRUE
				if("use_exp_restrictions_admin_bypass")
					use_exp_restrictions_admin_bypass = TRUE
				if("lobby_countdown")
					lobby_countdown = text2num(value)
				if("round_end_countdown")
					round_end_countdown = text2num(value)
				if("log_ooc")
					log_ooc = 1
				if("log_access")
					log_access = 1
				if("log_say")
					log_say = 1
				if("log_admin")
					log_admin = 1
				if("log_prayer")
					log_prayer = 1
				if("log_law")
					log_law = 1
				if("log_game")
					log_game = 1
				if("log_vote")
					log_vote = 1
				if("log_whisper")
					log_whisper = 1
				if("log_attack")
					log_attack = 1
				if("log_emote")
					log_emote = 1
				if("log_adminchat")
					log_adminchat = 1
				if("log_pda")
					log_pda = 1
				if("log_twitter")
					log_twitter = 1
				if("log_world_topic")
					log_world_topic = 1
				if("allow_admin_ooccolor")
					allow_admin_ooccolor = 1
				if("allow_vote_restart")
					allow_vote_restart = 1
				if("allow_vote_mode")
					allow_vote_mode = 1
				if("no_dead_vote")
					vote_no_dead = 1
				if("default_no_vote")
					vote_no_default = 1
				if("vote_delay")
					vote_delay = text2num(value)
				if("vote_period")
					vote_period = text2num(value)
				if("norespawn")
					respawn = 0
				if("servername")
					server_name = value
				if("serversqlname")
					server_sql_name = value
				if("stationname")
					station_name = value
				if("hostedby")
					hostedby = value
				if("server")
					server = value
				if("banappeals")
					banappeals = value
				if("wikiurl")
					wikiurl = value
				if("forumurl")
					forumurl = value
				if("rulesurl")
					rulesurl = value
				if("githuburl")
					githuburl = value
				if("githubrepoid")
					githubrepoid = value
				if("guest_jobban")
					guest_jobban = 1
				if("guest_ban")
					GLOB.guests_allowed = 0
				if("usewhitelist")
					usewhitelist = TRUE
				if("allow_metadata")
					allow_Metadata = 1
				if("id_console_jobslot_delay")
					id_console_jobslot_delay = text2num(value)
				if("inactivity_period")
					inactivity_period = text2num(value) * 10 //documented as seconds in config.txt
				if("afk_period")
					afk_period = text2num(value) * 10 // ^^^
				if("kick_inactive")
					kick_inactive = TRUE
				if("load_jobs_from_txt")
					load_jobs_from_txt = 1
				if("forbid_singulo_possession")
					forbid_singulo_possession = 1
				if("popup_admin_pm")
					popup_admin_pm = 1
				if("allow_holidays")
					allow_holidays = 1
				if("useircbot")	//tgs2 support
					useircbot = 1
				if("ticklag")
					var/ticklag = text2num(value)
					if(ticklag > 0)
						fps = 10 / ticklag
				if("tick_limit_mc_init")
					tick_limit_mc_init = text2num(value)
				if("fps")
					fps = text2num(value)
				if("automute_on")
					automute_on = 1
				if("panic_server_name")
					if (value != "\[Put the name here\]")
						panic_server_name = value
				if("panic_server_address")
					if(value != "byond://address:port")
						panic_address = value
				if("invoke_youtubedl")
					invoke_youtubedl = value
				if("show_irc_name")
					showircname = 1
				if("see_own_notes")
					see_own_notes = 1
				if("note_fresh_days")
					note_fresh_days = text2num(value)
				if("note_stale_days")
					note_stale_days = text2num(value)
				if("soft_popcap")
					soft_popcap = text2num(value)
				if("hard_popcap")
					hard_popcap = text2num(value)
				if("extreme_popcap")
					extreme_popcap = text2num(value)
				if("soft_popcap_message")
					soft_popcap_message = value
				if("hard_popcap_message")
					hard_popcap_message = value
				if("extreme_popcap_message")
					extreme_popcap_message = value
				if("panic_bunker")
					panic_bunker = 1
				if("notify_new_player_age")
					notify_new_player_age = text2num(value)
				if("notify_new_player_account_age")
					notify_new_player_account_age = text2num(value)
				if("irc_first_connection_alert")
					irc_first_connection_alert = 1
				if("check_randomizer")
					check_randomizer = 1
				if("ipintel_email")
					if (value != "ch@nge.me")
						ipintel_email = value
				if("ipintel_rating_bad")
					ipintel_rating_bad = text2num(value)
				if("ipintel_domain")
					ipintel_domain = value
				if("ipintel_save_good")
					ipintel_save_good = text2num(value)
				if("ipintel_save_bad")
					ipintel_save_bad = text2num(value)
				if("aggressive_changelog")
					aggressive_changelog = 1
				if("autoconvert_notes")
					autoconvert_notes = 1
				if("allow_webclient")
					allowwebclient = 1
				if("webclient_only_byond_members")
					webclientmembersonly = 1
				if("announce_admin_logout")
					announce_admin_logout = 1
				if("announce_admin_login")
					announce_admin_login = 1
				if("maprotation")
					maprotation = 1
				if("allow_map_voting")
					allow_map_voting = text2num(value)
				if("maprotationchancedelta")
					maprotatechancedelta = text2num(value)
				if("autoadmin")
					autoadmin = 1
					if(value)
						autoadmin_rank = ckeyEx(value)
				if("generate_minimaps")
					generate_minimaps = 1
				if("client_warn_version")
					client_warn_version = text2num(value)
				if("client_warn_message")
					client_warn_message = value
				if("client_error_version")
					client_error_version = text2num(value)
				if("client_error_message")
					client_error_message = value
				if("minute_topic_limit")
					minutetopiclimit = text2num(value)
				if("second_topic_limit")
					secondtopiclimit = text2num(value)
				if("error_cooldown")
					error_cooldown = text2num(value)
				if("error_limit")
					error_limit = text2num(value)
				if("error_silence_time")
					error_silence_time = text2num(value)
				if("error_msg_delay")
					error_msg_delay = text2num(value)
				if("irc_announce_new_game")
					irc_announce_new_game = TRUE
				if("debug_admin_hrefs")
					debug_admin_hrefs = TRUE
				else
#if DM_VERSION > 511
#error Replace the line below with WRITE_FILE(GLOB.config_error_log, "Unknown setting in configuration: '[name]'")
#endif
					HandleCommsConfig(name, value)	//TODO: Deprecate this eventually
		else if(type == "comms")
			HandleCommsConfig(name, value)
		else if(type == "game_options")
			switch(name)
				if("damage_multiplier")
					damage_multiplier		= text2num(value)
				if("revival_pod_plants")
					revival_pod_plants		= TRUE
				if("revival_cloning")
					revival_cloning			= TRUE
				if("revival_brain_life")
					revival_brain_life		= text2num(value)
				if("rename_cyborg")
					rename_cyborg			= 1
				if("ooc_during_round")
					ooc_during_round			= 1
				if("emojis")
					emojis					= 1
				if("no_credits_round_end")
					no_credits_round_end	= TRUE
				if("run_delay")
					run_speed				= text2num(value)
				if("walk_delay")
					walk_speed				= text2num(value)
				if("human_delay")
					human_delay				= text2num(value)
				if("robot_delay")
					robot_delay				= text2num(value)
				if("monkey_delay")
					monkey_delay				= text2num(value)
				if("alien_delay")
					alien_delay				= text2num(value)
				if("slime_delay")
					slime_delay				= text2num(value)
				if("animal_delay")
					animal_delay				= text2num(value)
				if("alert_red_upto")
					alert_desc_red_upto		= value
				if("alert_red_downto")
					alert_desc_red_downto	= value
				if("alert_blue_downto")
					alert_desc_blue_downto	= value
				if("alert_blue_upto")
					alert_desc_blue_upto		= value
				if("alert_green")
					alert_desc_green			= value
				if("alert_delta")
					alert_desc_delta			= value
				if("no_intercept_report")
					intercept				= 0
				if("assistants_have_maint_access")
					jobs_have_maint_access	|= ASSISTANTS_HAVE_MAINT_ACCESS
				if("security_has_maint_access")
					jobs_have_maint_access	|= SECURITY_HAS_MAINT_ACCESS
				if("everyone_has_maint_access")
					jobs_have_maint_access	|= EVERYONE_HAS_MAINT_ACCESS
				if("sec_start_brig")
					sec_start_brig			= 1
				if("gateway_delay")
					gateway_delay			= text2num(value)
				if("continuous")
					var/mode_name = lowertext(value)
					if(mode_name in modes)
						continuous[mode_name] = 1
					else
						WRITE_FILE(GLOB.config_error_log, "Unknown continuous configuration definition: [mode_name].")
				if("midround_antag")
					var/mode_name = lowertext(value)
					if(mode_name in modes)
						midround_antag[mode_name] = 1
					else
						WRITE_FILE(GLOB.config_error_log, "Unknown midround antagonist configuration definition: [mode_name].")
				if("midround_antag_time_check")
					midround_antag_time_check = text2num(value)
				if("midround_antag_life_check")
					midround_antag_life_check = text2num(value)
				if("min_pop")
					var/pop_pos = findtext(value, " ")
					var/mode_name = null
					var/mode_value = null

					if(pop_pos)
						mode_name = lowertext(copytext(value, 1, pop_pos))
						mode_value = copytext(value, pop_pos + 1)
						if(mode_name in modes)
							min_pop[mode_name] = text2num(mode_value)
						else
							WRITE_FILE(GLOB.config_error_log, "Unknown minimum population configuration definition: [mode_name].")
					else
						WRITE_FILE(GLOB.config_error_log, "Incorrect minimum population configuration definition: [mode_name]  [mode_value].")
				if("max_pop")
					var/pop_pos = findtext(value, " ")
					var/mode_name = null
					var/mode_value = null

					if(pop_pos)
						mode_name = lowertext(copytext(value, 1, pop_pos))
						mode_value = copytext(value, pop_pos + 1)
						if(mode_name in modes)
							max_pop[mode_name] = text2num(mode_value)
						else
							WRITE_FILE(GLOB.config_error_log, "Unknown maximum population configuration definition: [mode_name].")
					else
						WRITE_FILE(GLOB.config_error_log, "Incorrect maximum population configuration definition: [mode_name]  [mode_value].")
				if("shuttle_refuel_delay")
					shuttle_refuel_delay     = text2num(value)
				if("show_game_type_odds")
					show_game_type_odds		= 1
				if("ghost_interaction")
					ghost_interaction		= 1
				if("traitor_scaling_coeff")
					traitor_scaling_coeff	= text2num(value)
				if("changeling_scaling_coeff")
					changeling_scaling_coeff	= text2num(value)
				if("security_scaling_coeff")
					security_scaling_coeff	= text2num(value)
				if("abductor_scaling_coeff")
					abductor_scaling_coeff	= text2num(value)
				if("traitor_objectives_amount")
					traitor_objectives_amount = text2num(value)
				if("probability")
					var/prob_pos = findtext(value, " ")
					var/prob_name = null
					var/prob_value = null

					if(prob_pos)
						prob_name = lowertext(copytext(value, 1, prob_pos))
						prob_value = copytext(value, prob_pos + 1)
						if(prob_name in modes)
							probabilities[prob_name] = text2num(prob_value)
						else
							WRITE_FILE(GLOB.config_error_log, "Unknown game mode probability configuration definition: [prob_name].")
					else
						WRITE_FILE(GLOB.config_error_log, "Incorrect probability configuration definition: [prob_name]  [prob_value].")

				if("protect_roles_from_antagonist")
					protect_roles_from_antagonist	= 1
				if("protect_assistant_from_antagonist")
					protect_assistant_from_antagonist	= 1
				if("enforce_human_authority")
					enforce_human_authority	= 1
				if("allow_latejoin_antagonists")
					allow_latejoin_antagonists	= 1
				if("allow_random_events")
					allow_random_events		= 1

				if("events_min_time_mul")
					events_min_time_mul		= text2num(value)
				if("events_min_players_mul")
					events_min_players_mul	= text2num(value)

				if("minimal_access_threshold")
					minimal_access_threshold	= text2num(value)
				if("jobs_have_minimal_access")
					jobs_have_minimal_access	= 1
				if("humans_need_surnames")
					humans_need_surnames			= 1
				if("force_random_names")
					force_random_names		= 1
				if("allow_ai")
					allow_ai					= 1
				if("disable_secborg")
					forbid_secborg			= 1
				if("disable_peaceborg")
					forbid_peaceborg			= 1
				if("silent_ai")
					silent_ai 				= 1
				if("silent_borg")
					silent_borg				= 1
				if("sandbox_autoclose")
					sandbox_autoclose		= 1
				if("default_laws")
					default_laws				= text2num(value)
				if("random_laws")
					var/law_id = lowertext(value)
					lawids += law_id
				if("law_weight")
					// Value is in the form "LAWID,NUMBER"
					var/list/L = splittext(value, ",")
					if(L.len != 2)
						WRITE_FILE(GLOB.config_error_log, "Invalid LAW_WEIGHT: " + t)
						continue
					var/lawid = L[1]
					var/weight = text2num(L[2])
					law_weights[lawid] = weight

				if("silicon_max_law_amount")
					silicon_max_law_amount	= text2num(value)
				if("join_with_mutant_race")
					mutant_races				= 1
				if("roundstart_races")
					var/race_id = lowertext(value)
					for(var/species_id in GLOB.species_list)
						if(species_id == race_id)
							roundstart_races += GLOB.species_list[species_id]
							GLOB.roundstart_species[species_id] = GLOB.species_list[species_id]
				if("join_with_mutant_humans")
					mutant_humans			= 1
				if("assistant_cap")
					assistant_cap			= text2num(value)
				if("starlight")
					starlight			= 1
				if("grey_assistants")
					grey_assistants			= 1
				if("lavaland_budget")
					lavaland_budget			= text2num(value)
				if("space_budget")
					space_budget			= text2num(value)
				if("no_summon_guns")
					no_summon_guns			= 1
				if("no_summon_magic")
					no_summon_magic			= 1
				if("no_summon_events")
					no_summon_events			= 1
				if("reactionary_explosions")
					reactionary_explosions	= 1
				if("bombcap")
					var/BombCap = text2num(value)
					if (!BombCap)
						continue
					if (BombCap < 4)
						BombCap = 4

					GLOB.MAX_EX_DEVESTATION_RANGE = round(BombCap/4)
					GLOB.MAX_EX_HEAVY_RANGE = round(BombCap/2)
					GLOB.MAX_EX_LIGHT_RANGE = BombCap
					GLOB.MAX_EX_FLASH_RANGE = BombCap
					GLOB.MAX_EX_FLAME_RANGE = BombCap
				if("arrivals_shuttle_dock_window")
					arrivals_shuttle_dock_window = max(PARALLAX_LOOP_TIME, text2num(value))
				if("arrivals_shuttle_require_safe_latejoin")
					arrivals_shuttle_require_safe_latejoin = TRUE
				if("mice_roundstart")
					mice_roundstart = text2num(value)
				else
					WRITE_FILE(GLOB.config_error_log, "Unknown setting in configuration: '[name]'")
		else if(type == "policies")
			policies[name] = value

	fps = round(fps)
	if(fps <= 0)
		fps = initial(fps)

/datum/configuration/proc/HandleCommsConfig(name, value)
	switch(name)
		if("comms_key")
			global.comms_key = value
			if(value != "default_pwd" && length(value) > 6) //It's the default value or less than 6 characters long, warn badmins
				global.comms_allowed = TRUE
		if("cross_server_address")
			cross_address = value
			if(value != "byond:\\address:port")
				cross_allowed = TRUE
		if("cross_comms_name")
			cross_name = value
		if("medal_hub_address")
			global.medal_hub = value
		if("medal_hub_password")
			global.medal_pass = value
		else
			WRITE_FILE(GLOB.config_error_log, "Unknown setting in configuration: '[name]'")

/datum/configuration/proc/loadmaplist(filename)
	filename = "[GLOB.config_dir][filename]"
	var/list/Lines = world.file2list(filename)

	var/datum/map_config/currentmap = null
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/command = null
		var/data = null

		if(pos)
			command = lowertext(copytext(t, 1, pos))
			data = copytext(t, pos + 1)
		else
			command = lowertext(t)

		if(!command)
			continue

		if (!currentmap && command != "map")
			continue

		switch (command)
			if ("map")
				currentmap = new ("_maps/[data].json")
				if(currentmap.defaulted)
					log_world("Failed to load map config for [data]!")
			if ("minplayers","minplayer")
				currentmap.config_min_users = text2num(data)
			if ("maxplayers","maxplayer")
				currentmap.config_max_users = text2num(data)
			if ("weight","voteweight")
				currentmap.voteweight = text2num(data)
			if ("default","defaultmap")
				defaultmap = currentmap
			if ("endmap")
				maplist[currentmap.map_name] = currentmap
				currentmap = null
			if ("disabled")
				currentmap = null
			else
				WRITE_FILE(GLOB.config_error_log, "Unknown command in map vote config: '[command]'")


/datum/configuration/proc/loadsql(filename)
	filename = "[GLOB.config_dir][filename]"
	var/list/Lines = world.file2list(filename)
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if(pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if(!name)
			continue

		switch(name)
			if("sql_enabled")
				sql_enabled = 1
			if("address")
				global.sqladdress = value
			if("port")
				global.sqlport = value
			if("feedback_database")
				global.sqlfdbkdb = value
			if("feedback_login")
				global.sqlfdbklogin = value
			if("feedback_password")
				global.sqlfdbkpass = value
			if("feedback_tableprefix")
				global.sqlfdbktableprefix = value
			else
				WRITE_FILE(GLOB.config_error_log, "Unknown setting in configuration: '[name]'")

/datum/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = new T()
		if(M.config_tag && M.config_tag == mode_name)
			return M
		qdel(M)
	return new /datum/game_mode/extended()

/datum/configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = new T()
		//to_chat(world, "DEBUG: [T], tag=[M.config_tag], prob=[probabilities[M.config_tag]]")
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(min_pop[M.config_tag])
			M.required_players = min_pop[M.config_tag]
		if(max_pop[M.config_tag])
			M.maximum_players = max_pop[M.config_tag]
		if(M.can_start())
			runnable_modes[M] = probabilities[M.config_tag]
			//to_chat(world, "DEBUG: runnable_mode\[[runnable_modes.len]\] = [M.config_tag]")
	return runnable_modes

/datum/configuration/proc/get_runnable_midround_modes(crew)
	var/list/datum/game_mode/runnable_modes = new
	for(var/T in (gamemode_cache - SSticker.mode.type))
		var/datum/game_mode/M = new T()
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(min_pop[M.config_tag])
			M.required_players = min_pop[M.config_tag]
		if(max_pop[M.config_tag])
			M.maximum_players = max_pop[M.config_tag]
		if(M.required_players <= crew)
			if(M.maximum_players >= 0 && M.maximum_players < crew)
				continue
			runnable_modes[M] = probabilities[M.config_tag]
	return runnable_modes

/datum/configuration/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Edit", src)

	stat("[name]:", statclick)
