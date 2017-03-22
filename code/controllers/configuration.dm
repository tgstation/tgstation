//Configuraton defines //TODO: Move all yes/no switches into bitflags

//Used by jobs_have_maint_access
#define ASSISTANTS_HAVE_MAINT_ACCESS 1
#define SECURITY_HAS_MAINT_ACCESS 2
#define EVERYONE_HAS_MAINT_ACCESS 4

/datum/configuration/vv_get_var(var_name)
	var/static/list/banned_views = list("autoadmin", "autoadmin_rank")
	if(var_name in banned_views)
		return debug_variable(var_name, "SECRET", 0, src)
	return ..()

/datum/configuration/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("cross_address", "cross_allowed", "autoadmin", "autoadmin_rank")
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
	var/log_hrefs = 0					// log all links clicked in-game. Could be used for debugging and tracking down exploits
	var/log_twitter = 0					// log certain expliotable parrots and other such fun things in a JSON file of twitter valid phrases.
	var/log_world_topic = 0				// log all world.Topic() calls
	var/log_runtimes = FALSE			// log runtimes into a file
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
	var/kick_inactive = 0				//force disconnect for inactive players
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

	var/allow_panic_bunker_bounce = 0 //Send new players somewhere else
	var/panic_server_name = "somewhere else"
	var/panic_address = "byond://" //Reconnect a player this linked server if this server isn't accepting new players

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

	var/revival_pod_plants = 1
	var/revival_cloning = 1
	var/revival_brain_life = -1

	var/rename_cyborg = 0
	var/ooc_during_round = 0
	var/emojis = 0

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

	var/sandbox_autoclose = 0 // close the sandbox panel after spawning an item, potentially reducing griff

	var/default_laws = 0 //Controls what laws the AI spawns with.
	var/silicon_max_law_amount = 12
	var/list/lawids = list()

	var/list/law_weights = list()

	var/assistant_cap = -1

	var/starlight = 0
	var/generate_minimaps = 0
	var/grey_assistants = 0

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

/datum/configuration/New()
	gamemode_cache = typecacheof(/datum/game_mode,TRUE)
	for(var/T in gamemode_cache)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if(M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				diary << "Adding game mode [M.name] ([M.config_tag]) to configuration."
				modes += M.config_tag
				mode_names[M.config_tag] = M.name
				probabilities[M.config_tag] = M.probability
				if(M.votable)
					votable_modes += M.config_tag
		qdel(M)
	votable_modes += "secret"

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	var/list/Lines = file2list(filename)

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
					config.hub = 1
				if("admin_legacy_system")
					config.admin_legacy_system = 1
				if("ban_legacy_system")
					config.ban_legacy_system = 1
				if("use_age_restriction_for_jobs")
					config.use_age_restriction_for_jobs = 1
				if("use_account_age_for_jobs")
					config.use_account_age_for_jobs = 1
				if("lobby_countdown")
					config.lobby_countdown = text2num(value)
				if("round_end_countdown")
					config.round_end_countdown = text2num(value)
				if("log_ooc")
					config.log_ooc = 1
				if("log_access")
					config.log_access = 1
				if("log_say")
					config.log_say = 1
				if("log_admin")
					config.log_admin = 1
				if("log_prayer")
					config.log_prayer = 1
				if("log_law")
					config.log_law = 1
				if("log_game")
					config.log_game = 1
				if("log_vote")
					config.log_vote = 1
				if("log_whisper")
					config.log_whisper = 1
				if("log_attack")
					config.log_attack = 1
				if("log_emote")
					config.log_emote = 1
				if("log_adminchat")
					config.log_adminchat = 1
				if("log_pda")
					config.log_pda = 1
				if("log_hrefs")
					config.log_hrefs = 1
				if("log_twitter")
					config.log_twitter = 1
				if("log_world_topic")
					config.log_world_topic = 1
				if("allow_admin_ooccolor")
					config.allow_admin_ooccolor = 1
				if("allow_vote_restart")
					config.allow_vote_restart = 1
				if("allow_vote_mode")
					config.allow_vote_mode = 1
				if("no_dead_vote")
					config.vote_no_dead = 1
				if("default_no_vote")
					config.vote_no_default = 1
				if("vote_delay")
					config.vote_delay = text2num(value)
				if("vote_period")
					config.vote_period = text2num(value)
				if("norespawn")
					config.respawn = 0
				if("servername")
					config.server_name = value
				if("serversqlname")
					config.server_sql_name = value
				if("stationname")
					config.station_name = value
				if("hostedby")
					config.hostedby = value
				if("server")
					config.server = value
				if("banappeals")
					config.banappeals = value
				if("wikiurl")
					config.wikiurl = value
				if("forumurl")
					config.forumurl = value
				if("rulesurl")
					config.rulesurl = value
				if("githuburl")
					config.githuburl = value
				if("githubrepoid")
					config.githubrepoid = value
				if("guest_jobban")
					config.guest_jobban = 1
				if("guest_ban")
					guests_allowed = 0
				if("usewhitelist")
					config.usewhitelist = TRUE
				if("allow_metadata")
					config.allow_Metadata = 1
				if("kick_inactive")
					if(value < 1)
						value = INACTIVITY_KICK
					config.kick_inactive = value
				if("load_jobs_from_txt")
					load_jobs_from_txt = 1
				if("forbid_singulo_possession")
					forbid_singulo_possession = 1
				if("popup_admin_pm")
					config.popup_admin_pm = 1
				if("allow_holidays")
					config.allow_holidays = 1
				if("useircbot")
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
				if("comms_key")
					global.comms_key = value
					if(value != "default_pwd" && length(value) > 6) //It's the default value or less than 6 characters long, warn badmins
						global.comms_allowed = 1
				if("cross_server_address")
					cross_address = value
					if(value != "byond:\\address:port")
						cross_allowed = 1
				if("cross_comms_name")
					cross_name = value
				if("panic_server_name")
					panic_server_name = value
				if("panic_server_address")
					panic_address = value
					if(value != "byond:\\address:port")
						allow_panic_bunker_bounce = 1
				if("medal_hub_address")
					global.medal_hub = value
				if("medal_hub_password")
					global.medal_pass = value
				if("show_irc_name")
					config.showircname = 1
				if("see_own_notes")
					config.see_own_notes = 1
				if("soft_popcap")
					config.soft_popcap = text2num(value)
				if("hard_popcap")
					config.hard_popcap = text2num(value)
				if("extreme_popcap")
					config.extreme_popcap = text2num(value)
				if("soft_popcap_message")
					config.soft_popcap_message = value
				if("hard_popcap_message")
					config.hard_popcap_message = value
				if("extreme_popcap_message")
					config.extreme_popcap_message = value
				if("panic_bunker")
					config.panic_bunker = 1
				if("notify_new_player_age")
					config.notify_new_player_age = text2num(value)
				if("irc_first_connection_alert")
					config.irc_first_connection_alert = 1
				if("check_randomizer")
					config.check_randomizer = 1
				if("ipintel_email")
					if (value != "ch@nge.me")
						config.ipintel_email = value
				if("ipintel_rating_bad")
					config.ipintel_rating_bad = text2num(value)
				if("ipintel_domain")
					config.ipintel_domain = value
				if("ipintel_save_good")
					config.ipintel_save_good = text2num(value)
				if("ipintel_save_bad")
					config.ipintel_save_bad = text2num(value)
				if("aggressive_changelog")
					config.aggressive_changelog = 1
				if("log_runtimes")
					log_runtimes = TRUE
					var/newlog = file("data/logs/runtimes/runtime-[time2text(world.realtime, "YYYY-MM-DD")].log")
					if(runtime_diary != newlog)
						world.log << "Now logging runtimes to data/logs/runtimes/runtime-[time2text(world.realtime, "YYYY-MM-DD")].log"
						runtime_diary = newlog
				if("autoconvert_notes")
					config.autoconvert_notes = 1
				if("allow_webclient")
					config.allowwebclient = 1
				if("webclient_only_byond_members")
					config.webclientmembersonly = 1
				if("announce_admin_logout")
					config.announce_admin_logout = 1
				if("announce_admin_login")
					config.announce_admin_login = 1
				if("maprotation")
					config.maprotation = 1
				if("allow_map_voting")
					config.allow_map_voting = text2num(value)
				if("maprotationchancedelta")
					config.maprotatechancedelta = text2num(value)
				if("autoadmin")
					config.autoadmin = 1
					if(value)
						config.autoadmin_rank = ckeyEx(value)
				if("generate_minimaps")
					config.generate_minimaps = 1
				if("client_warn_version")
					config.client_warn_version = text2num(value)
				if("client_warn_message")
					config.client_warn_message = value
				if("client_error_version")
					config.client_error_version = text2num(value)
				if("client_error_message")
					config.client_error_message = value
				if("minute_topic_limit")
					config.minutetopiclimit = text2num(value)
				if("second_topic_limit")
					config.secondtopiclimit = text2num(value)
				if("error_cooldown")
					error_cooldown = text2num(value)
				if("error_limit")
					error_limit = text2num(value)
				if("error_silence_time")
					error_silence_time = text2num(value)
				if("error_msg_delay")
					error_msg_delay = text2num(value)
				else
					diary << "Unknown setting in configuration: '[name]'"

		else if(type == "game_options")
			switch(name)
				if("damage_multiplier")
					config.damage_multiplier		= text2num(value)
				if("revival_pod_plants")
					config.revival_pod_plants		= text2num(value)
				if("revival_cloning")
					config.revival_cloning			= text2num(value)
				if("revival_brain_life")
					config.revival_brain_life		= text2num(value)
				if("rename_cyborg")
					config.rename_cyborg			= 1
				if("ooc_during_round")
					config.ooc_during_round			= 1
				if("emojis")
					config.emojis					= 1
				if("run_delay")
					config.run_speed				= text2num(value)
				if("walk_delay")
					config.walk_speed				= text2num(value)
				if("human_delay")
					config.human_delay				= text2num(value)
				if("robot_delay")
					config.robot_delay				= text2num(value)
				if("monkey_delay")
					config.monkey_delay				= text2num(value)
				if("alien_delay")
					config.alien_delay				= text2num(value)
				if("slime_delay")
					config.slime_delay				= text2num(value)
				if("animal_delay")
					config.animal_delay				= text2num(value)
				if("alert_red_upto")
					config.alert_desc_red_upto		= value
				if("alert_red_downto")
					config.alert_desc_red_downto	= value
				if("alert_blue_downto")
					config.alert_desc_blue_downto	= value
				if("alert_blue_upto")
					config.alert_desc_blue_upto		= value
				if("alert_green")
					config.alert_desc_green			= value
				if("alert_delta")
					config.alert_desc_delta			= value
				if("no_intercept_report")
					config.intercept				= 0
				if("assistants_have_maint_access")
					config.jobs_have_maint_access	|= ASSISTANTS_HAVE_MAINT_ACCESS
				if("security_has_maint_access")
					config.jobs_have_maint_access	|= SECURITY_HAS_MAINT_ACCESS
				if("everyone_has_maint_access")
					config.jobs_have_maint_access	|= EVERYONE_HAS_MAINT_ACCESS
				if("sec_start_brig")
					config.sec_start_brig			= 1
				if("gateway_delay")
					config.gateway_delay			= text2num(value)
				if("continuous")
					var/mode_name = lowertext(value)
					if(mode_name in config.modes)
						config.continuous[mode_name] = 1
					else
						diary << "Unknown continuous configuration definition: [mode_name]."
				if("midround_antag")
					var/mode_name = lowertext(value)
					if(mode_name in config.modes)
						config.midround_antag[mode_name] = 1
					else
						diary << "Unknown midround antagonist configuration definition: [mode_name]."
				if("midround_antag_time_check")
					config.midround_antag_time_check = text2num(value)
				if("midround_antag_life_check")
					config.midround_antag_life_check = text2num(value)
				if("min_pop")
					var/pop_pos = findtext(value, " ")
					var/mode_name = null
					var/mode_value = null

					if(pop_pos)
						mode_name = lowertext(copytext(value, 1, pop_pos))
						mode_value = copytext(value, pop_pos + 1)
						if(mode_name in config.modes)
							config.min_pop[mode_name] = text2num(mode_value)
						else
							diary << "Unknown minimum population configuration definition: [mode_name]."
					else
						diary << "Incorrect minimum population configuration definition: [mode_name]  [mode_value]."
				if("max_pop")
					var/pop_pos = findtext(value, " ")
					var/mode_name = null
					var/mode_value = null

					if(pop_pos)
						mode_name = lowertext(copytext(value, 1, pop_pos))
						mode_value = copytext(value, pop_pos + 1)
						if(mode_name in config.modes)
							config.max_pop[mode_name] = text2num(mode_value)
						else
							diary << "Unknown maximum population configuration definition: [mode_name]."
					else
						diary << "Incorrect maximum population configuration definition: [mode_name]  [mode_value]."
				if("shuttle_refuel_delay")
					config.shuttle_refuel_delay     = text2num(value)
				if("show_game_type_odds")
					config.show_game_type_odds		= 1
				if("ghost_interaction")
					config.ghost_interaction		= 1
				if("traitor_scaling_coeff")
					config.traitor_scaling_coeff	= text2num(value)
				if("changeling_scaling_coeff")
					config.changeling_scaling_coeff	= text2num(value)
				if("security_scaling_coeff")
					config.security_scaling_coeff	= text2num(value)
				if("abductor_scaling_coeff")
					config.abductor_scaling_coeff	= text2num(value)
				if("traitor_objectives_amount")
					config.traitor_objectives_amount = text2num(value)
				if("probability")
					var/prob_pos = findtext(value, " ")
					var/prob_name = null
					var/prob_value = null

					if(prob_pos)
						prob_name = lowertext(copytext(value, 1, prob_pos))
						prob_value = copytext(value, prob_pos + 1)
						if(prob_name in config.modes)
							config.probabilities[prob_name] = text2num(prob_value)
						else
							diary << "Unknown game mode probability configuration definition: [prob_name]."
					else
						diary << "Incorrect probability configuration definition: [prob_name]  [prob_value]."

				if("protect_roles_from_antagonist")
					config.protect_roles_from_antagonist	= 1
				if("protect_assistant_from_antagonist")
					config.protect_assistant_from_antagonist	= 1
				if("enforce_human_authority")
					config.enforce_human_authority	= 1
				if("allow_latejoin_antagonists")
					config.allow_latejoin_antagonists	= 1
				if("allow_random_events")
					config.allow_random_events		= 1

				if("events_min_time_mul")
					config.events_min_time_mul		= text2num(value)
				if("events_min_players_mul")
					config.events_min_players_mul	= text2num(value)

				if("minimal_access_threshold")
					config.minimal_access_threshold	= text2num(value)
				if("jobs_have_minimal_access")
					config.jobs_have_minimal_access	= 1
				if("humans_need_surnames")
					humans_need_surnames			= 1
				if("force_random_names")
					config.force_random_names		= 1
				if("allow_ai")
					config.allow_ai					= 1
				if("disable_secborg")
					config.forbid_secborg			= 1
				if("disable_peaceborg")
					config.forbid_peaceborg			= 1
				if("silent_ai")
					config.silent_ai 				= 1
				if("silent_borg")
					config.silent_borg				= 1
				if("sandbox_autoclose")
					config.sandbox_autoclose		= 1
				if("default_laws")
					config.default_laws				= text2num(value)
				if("random_laws")
					var/law_id = lowertext(value)
					lawids += law_id
				if("law_weight")
					// Value is in the form "LAWID,NUMBER"
					var/list/L = splittext(value, ",")
					if(L.len != 2)
						diary << "Invalid LAW_WEIGHT: " + t
						continue
					var/lawid = L[1]
					var/weight = text2num(L[2])
					law_weights[lawid] = weight

				if("silicon_max_law_amount")
					config.silicon_max_law_amount	= text2num(value)
				if("join_with_mutant_race")
					config.mutant_races				= 1
				if("roundstart_races")
					var/race_id = lowertext(value)
					for(var/species_id in species_list)
						if(species_id == race_id)
							roundstart_races += species_list[species_id]
							roundstart_species[species_id] = species_list[species_id]
				if("join_with_mutant_humans")
					config.mutant_humans			= 1
				if("assistant_cap")
					config.assistant_cap			= text2num(value)
				if("starlight")
					config.starlight			= 1
				if("grey_assistants")
					config.grey_assistants			= 1
				if("lavaland_budget")
					config.lavaland_budget			= text2num(value)
				if("space_budget")
					config.space_budget			= text2num(value)
				if("no_summon_guns")
					config.no_summon_guns			= 1
				if("no_summon_magic")
					config.no_summon_magic			= 1
				if("no_summon_events")
					config.no_summon_events			= 1
				if("reactionary_explosions")
					config.reactionary_explosions	= 1
				if("bombcap")
					var/BombCap = text2num(value)
					if (!BombCap)
						continue
					if (BombCap < 4)
						BombCap = 4

					MAX_EX_DEVESTATION_RANGE = round(BombCap/4)
					MAX_EX_HEAVY_RANGE = round(BombCap/2)
					MAX_EX_LIGHT_RANGE = BombCap
					MAX_EX_FLASH_RANGE = BombCap
					MAX_EX_FLAME_RANGE = BombCap
				if("arrivals_shuttle_dock_window")
					config.arrivals_shuttle_dock_window = max(PARALLAX_LOOP_TIME, text2num(value))
				if("arrivals_shuttle_require_safe_latejoin")
					config.arrivals_shuttle_require_safe_latejoin = text2num(value)
				else
					diary << "Unknown setting in configuration: '[name]'"

	fps = round(fps)
	if(fps <= 0)
		fps = initial(fps)


/datum/configuration/proc/loadmaplist(filename)
	var/list/Lines = file2list(filename)

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
				config.defaultmap = currentmap
			if ("endmap")
				config.maplist[currentmap.map_name] = currentmap
				currentmap = null
			else
				diary << "Unknown command in map vote config: '[command]'"


/datum/configuration/proc/loadsql(filename)
	var/list/Lines = file2list(filename)
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
				config.sql_enabled = 1
			if("address")
				sqladdress = value
			if("port")
				sqlport = value
			if("feedback_database")
				sqlfdbkdb = value
			if("feedback_login")
				sqlfdbklogin = value
			if("feedback_password")
				sqlfdbkpass = value
			if("feedback_tableprefix")
				sqlfdbktableprefix = value
			else
				diary << "Unknown setting in configuration: '[name]'"

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