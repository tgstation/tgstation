//Configuraton defines //TODO: Move all yes/no switches into bitflags

//Used by jobs_have_maint_access
#define ASSISTANTS_HAVE_MAINT_ACCESS 1
#define SECURITY_HAS_MAINT_ACCESS 2
#define EVERYONE_HAS_MAINT_ACCESS 4

/datum/configuration
	var/server_name = null				// server name (the name of the game window)
	var/station_name = null				// station name (the name of the station in-game)
	var/server_suffix = 0				// generate numeric suffix based on server port
	var/lobby_countdown = 120			// In between round countdown.

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
	var/log_hrefs = 0					// logs all links clicked in-game. Could be used for debugging and tracking down exploits
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
	var/fps = 10
	var/Tickcomp = 0
	var/allow_holidays = 0				//toggles whether holiday-specific content should be used

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

	var/forbid_singulo_possession = 0
	var/useircbot = 0

	var/admin_legacy_system = 0	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
	var/use_age_restriction_for_jobs = 0 //Do jobs use account age restrictions? --requires database
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

	var/humans_need_surnames = 0
	var/allow_random_events = 0			// enables random events mid-round when set to 1
	var/allow_ai = 0					// allow ai job
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
	var/mutant_humans = 0				//players can pick mutant bodyparts for humans before joining the game

	var/no_summon_guns		//No
	var/no_summon_magic		//Fun
	var/no_summon_events	//Allowed

	var/alert_desc_green = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/alert_desc_blue_upto = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."
	var/alert_desc_blue_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	var/alert_desc_red_upto = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	var/alert_desc_red_downto = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	var/alert_desc_delta = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

	var/health_threshold_crit = 0
	var/health_threshold_dead = -100

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

	var/sandbox_autoclose = 0 // close the sandbox panel after spawning an item, potentially reducing griff

	var/default_laws = 0 //Controls what laws the AI spawns with.
	var/silicon_max_law_amount = 12

	var/assistant_cap = -1

	var/starlight = 0
	var/grey_assistants = 0

	var/aggressive_changelog = 0

	var/reactionary_explosions = 0 //If we use reactionary explosions, explosions that react to walls and doors

/datum/configuration/New()
	var/list/L = typesof(/datum/game_mode) - /datum/game_mode
	for(var/T in L)
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
		del(M)
	votable_modes += "secret"

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	var/list/Lines = file2list(filename)

	for(var/t in Lines)
		if(!t)	continue

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
				if("admin_legacy_system")
					config.admin_legacy_system = 1
				if("ban_legacy_system")
					config.ban_legacy_system = 1
				if("use_age_restriction_for_jobs")
					config.use_age_restriction_for_jobs = 1
				if("lobby_countdown")
					config.lobby_countdown = text2num(value)
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
				if("stationname")
					config.station_name = value
				if("serversuffix")
					config.server_suffix = 1
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
				if("guest_jobban")
					config.guest_jobban = 1
				if("guest_ban")
					guests_allowed = 0
				if("usewhitelist")
					config.usewhitelist = 1
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
				if("fps")
					fps = text2num(value)
				if("tickcomp")
					Tickcomp = 1
				if("automute_on")
					automute_on = 1
				if("comms_key")
					global.comms_key = value
					if(value != "default_pwd" && length(value) > 6) //It's the default value or less than 6 characters long, warn badmins
						global.comms_allowed = 1
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
				if("aggressive_changelog")
					config.aggressive_changelog = 1
				else
					diary << "Unknown setting in configuration: '[name]'"

		else if(type == "game_options")
			switch(name)
				if("health_threshold_crit")
					config.health_threshold_crit	= text2num(value)
				if("health_threshold_dead")
					config.health_threshold_dead	= text2num(value)
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
				if("silent_ai")
					config.silent_ai 				= 1
				if("silent_borg")
					config.silent_borg				= 1
				if("sandbox_autoclose")
					config.sandbox_autoclose		= 1
				if("default_laws")
					config.default_laws				= text2num(value)
				if("silicon_max_law_amount")
					config.silicon_max_law_amount	= text2num(value)
				if("join_with_mutant_race")
					config.mutant_races				= 1
				if("join_with_mutant_humans")
					config.mutant_humans			= 1
				if("assistant_cap")
					config.assistant_cap			= text2num(value)
				if("starlight")
					config.starlight			= 1
				if("grey_assistants")
					config.grey_assistants			= 1
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
					if (BombCap > 128)
						BombCap = 128

					MAX_EX_DEVESTATION_RANGE = round(BombCap/4)
					MAX_EX_HEAVY_RANGE = round(BombCap/2)
					MAX_EX_LIGHT_RANGE = BombCap
					MAX_EX_FLASH_RANGE = BombCap
					MAX_EX_FLAME_RANGE = BombCap
				else
					diary << "Unknown setting in configuration: '[name]'"

	fps = round(fps)
	if(fps <= 0)
		fps = initial(fps)

/datum/configuration/proc/loadsql(filename)
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)	continue

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
	for(var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		if(M.config_tag && M.config_tag == mode_name)
			return M
		del(M)
	return new /datum/game_mode/extended()

/datum/configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	for(var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		//world << "DEBUG: [T], tag=[M.config_tag], prob=[probabilities[M.config_tag]]"
		if(!(M.config_tag in modes))
			del(M)
			continue
		if(probabilities[M.config_tag]<=0)
			del(M)
			continue
		if(M.can_start())
			runnable_modes[M] = probabilities[M.config_tag]
			//world << "DEBUG: runnable_mode\[[runnable_modes.len]\] = [M.config_tag]"
	return runnable_modes

/datum/configuration/proc/get_runnable_midround_modes(crew)
	var/list/datum/game_mode/runnable_modes = new
	for(var/T in (typesof(/datum/game_mode) - /datum/game_mode - ticker.mode.type))
		var/datum/game_mode/M = new T()
		if(!(M.config_tag in modes))
			qdel(M)
			continue
		if(probabilities[M.config_tag]<=0)
			qdel(M)
			continue
		if(M.required_players <= crew)
			runnable_modes[M] = probabilities[M.config_tag]
	return runnable_modes
