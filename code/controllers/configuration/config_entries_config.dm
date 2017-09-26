#define CURRENT_RESIDENT_FILE "config.txt"

CONFIG_DEF(/datum/config_entry/flag/autoadmin)  // if autoadmin is enabled

CONFIG_DEF(/datum/config_entry/string/autoadmin_rank)	// the rank for autoadmins
	value = "Game Master"

CONFIG_DEF(/datum/config_entry/string/servername)	// server name (the name of the game window)

CONFIG_DEF(/datum/config_entry/string/serversqlname)	// short form server name used for the DB

CONFIG_DEF(/datum/config_entry/string/stationname)	// station name (the name of the station in-game)

CONFIG_DEF(/datum/config_entry/number/clamped/lobby_countdown)	// In between round countdown.
	value = 120
	min_val = 0

CONFIG_DEF(/datum/config_entry/number/clamped/lobby_countdown)	// Post round murder death kill countdown
	value = 25
	min_val = 0

CONFIG_DEF(/datum/config_entry/flag/hub)	// if the game appears on the hub or not

CONFIG_DEF(/datum/config_entry/flag/log_ooc)	// log OOC channel

CONFIG_DEF(/datum/config_entry/flag/log_access)	// log login/logout

CONFIG_DEF(/datum/config_entry/flag/log_say)	// log client say

CONFIG_DEF(/datum/config_entry/flag/log_admin)	// log admin actions

CONFIG_DEF(/datum/config_entry/flag/log_prayer)	// log prayers

CONFIG_DEF(/datum/config_entry/flag/log_law)	// log lawchanges

CONFIG_DEF(/datum/config_entry/flag/log_game)	// log game events

CONFIG_DEF(/datum/config_entry/flag/log_vote)	// log voting

CONFIG_DEF(/datum/config_entry/flag/log_whisper)	// log client whisper

CONFIG_DEF(/datum/config_entry/flag/log_attack)	// log attack messages

CONFIG_DEF(/datum/config_entry/flag/log_emote)	// log emotes

CONFIG_DEF(/datum/config_entry/flag/log_adminchat)	// log admin chat messages

CONFIG_DEF(/datum/config_entry/flag/log_pda)	// log pda messages

CONFIG_DEF(/datum/config_entry/flag/log_twitter)	// log certain expliotable parrots and other such fun things in a JSON file of twitter valid phrases.

CONFIG_DEF(/datum/config_entry/flag/log_world_topic)	// log all world.Topic() calls

CONFIG_DEF(/datum/config_entry/flag/allow_admin_ooccolor)	// Allows admins with relevant permissions to have their own ooc colour

CONFIG_DEF(/datum/config_entry/flag/allow_vote_restart)	// allow votes to restart

CONFIG_DEF(/datum/config_entry/flag/allow_vote_mode)	// allow votes to change mode

CONFIG_DEF(/datum/config_entry/number/clamped/vote_delay)	// minimum time between voting sessions (deciseconds, 10 minute default)
	value = 6000
	min_val = 0

CONFIG_DEF(/datum/config_entry/number/clamped/vote_period)	// length of voting period (deciseconds, default 1 minute)
	value = 600
	min_val = 0
			
CONFIG_DEF(/datum/config_entry/flag/default_no_vote)	// vote does not default to nochange/norestart

CONFIG_DEF(/datum/config_entry/flag/no_dead_vote)	// dead people can't vote (tbi)

CONFIG_DEF(/datum/config_entry/flag/allow_metadata)	// Metadata is supported.

CONFIG_DEF(/datum/config_entry/flag/popup_admin_pm)	// adminPMs to non-admins show in a pop-up 'reply' window when set

CONFIG_DEF(/datum/config_entry/number/clamped/fps)
	value = 20
	min_val = 1
	max_val = 100   //byond will start crapping out at 50, so this is just ridic
	var/sync_validate = FALSE

/datum/config_entry/number/clamped/fps/ValidateAndSet(str_val)
	. = ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/clamped/ticklag/TL = config.entries_by_type[/datum/config_entry/number/clamped/ticklag]
		if(!TL.sync_validate)
			TL.ValidateAndSet(10 / value)
		sync_validate = FALSE

CONFIG_DEF(/datum/config_entry/number/clamped/ticklag)
	var/sync_validate = FALSE

/datum/config_entry/number/clamped/ticklag/New()	//ticklag weirdly just mirrors fps
	var/datum/config_entry/CE = /datum/config_entry/number/clamped/fps
	value = 10 / initial(CE.value)
	..()

/datum/config_entry/number/clamped/ticklag/ValidateAndSet(str_val)
	. = ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/clamped/fps/FPS = config.entries_by_type[/datum/config_entry/number/clamped/fps]
		if(!FPS.sync_validate)
			FPS.ValidateAndSet(10 / value)
		sync_validate = FALSE

CONFIG_DEF(/datum/config_entry/flag/allow_holidays)

CONFIG_DEF(/datum/config_entry/number/clamped/tick_limit_mc_init)	//SSinitialization throttling
	value = TICK_LIMIT_MC_INIT_DEFAULT
	min_val = 0 //oranges warned us

CONFIG_DEF(/datum/config_entry/flag/admin_legacy_system)	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system

CONFIG_DEF(/datum/config_entry/string/hostedby)

CONFIG_DEF(/datum/config_entry/flag/norespawn)

CONFIG_DEF(/datum/config_entry/flag/guest_jobban)

CONFIG_DEF(/datum/config_entry/flag/usewhitelist)

CONFIG_DEF(/datum/config_entry/flag/ban_legacy_system)	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system.

CONFIG_DEF(/datum/config_entry/flag/use_age_restriction_for_jobs)	//Do jobs use account age restrictions? --requires database

CONFIG_DEF(/datum/config_entry/flag/use_account_age_for_jobs)	//Uses the time they made the account for the job restriction stuff. New player joining alerts should be unaffected.

CONFIG_DEF(/datum/config_entry/flag/use_exp_tracking)

CONFIG_DEF(/datum/config_entry/flag/use_exp_restrictions_heads)

CONFIG_DEF(/datum/config_entry/number/clamped/use_exp_restrictions_heads_hours)
	min_val = 0

CONFIG_DEF(/datum/config_entry/flag/use_exp_restrictions_heads_department)

CONFIG_DEF(/datum/config_entry/flag/use_exp_restrictions_other)

CONFIG_DEF(/datum/config_entry/flag/use_exp_restrictions_admin_bypass)

CONFIG_DEF(/datum/config_entry/string/server)

CONFIG_DEF(/datum/config_entry/string/banappeals)

CONFIG_DEF(/datum/config_entry/string/wikiurl)
	value = "http://www.tgstation13.org/wiki"

CONFIG_DEF(/datum/config_entry/string/forumurl)
	value = "http://tgstation13.org/phpBB/index.php"

CONFIG_DEF(/datum/config_entry/string/rulesurl)
	value = "http://www.tgstation13.org/wiki/Rules"

CONFIG_DEF(/datum/config_entry/string/githuburl)
	value = "https://www.github.com/tgstation/-tg-station"

CONFIG_DEF(/datum/config_entry/number/clamped/githubrepoid)
	min_val = 0

CONFIG_DEF(/datum/config_entry/flag/guest_ban)

CONFIG_DEF(/datum/config_entry/number/clamped/id_console_jobslot_delay)
	min_val = 0

CONFIG_DEF(/datum/config_entry/number/clamped/inactivity_period)	//time in ds until a player is considered inactive)
	value = 3000
	min_val = 0

/datum/config_entry/number/clamped/inactivity_period/ValidateAndSet(str_val)
	. = ..()
	if(.)
		value *= 10 //documented as seconds in config.txt

CONFIG_DEF(/datum/config_entry/number/clamped/afk_period)	//time in ds until a player is considered inactive)
	value = 3000
	min_val = 0

/datum/config_entry/number/clamped/afk_period/ValidateAndSet(str_val)
	. = ..()
	if(.)
		value *= 10 //documented as seconds in config.txt

CONFIG_DEF(/datum/config_entry/flag/kick_inactive)	//force disconnect for inactive players

CONFIG_DEF(/datum/config_entry/flag/load_jobs_from_txt)

CONFIG_DEF(/datum/config_entry/flag/forbid_singulo_possession)

CONFIG_DEF(/datum/config_entry/flag/useircbot)	//tgs2 support

CONFIG_DEF(/datum/config_entry/flag/automute_on)	//enables automuting/spam prevention

CONFIG_DEF(/datum/config_entry/string/panic_server_name)

/datum/config_entry/string/panic_server_name/ValidateAndSet(str_val)
	return str_val != "\[Put the name here\]" && ..()

CONFIG_DEF(/datum/config_entry/string/panic_address)	//Reconnect a player this linked server if this server isn't accepting new players

/datum/config_entry/string/panic_address/ValidateAndSet(str_val)
	return str_val != "byond://address:port" && ..()

CONFIG_DEF(/datum/config_entry/string/invoke_youtubedl)