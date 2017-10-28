#define CURRENT_RESIDENT_FILE "config.txt"

CONFIG_DEF(flag/autoadmin)  // if autoadmin is enabled
	protection = CONFIG_ENTRY_LOCKED

CONFIG_DEF(string/autoadmin_rank)	// the rank for autoadmins
	value = "Game Master"
	protection = CONFIG_ENTRY_LOCKED

CONFIG_DEF(string/servername)	// server name (the name of the game window)

CONFIG_DEF(string/serversqlname)	// short form server name used for the DB

CONFIG_DEF(string/stationname)	// station name (the name of the station in-game)

CONFIG_DEF(number/lobby_countdown)	// In between round countdown.
	value = 120
	min_val = 0

CONFIG_DEF(number/round_end_countdown)	// Post round murder death kill countdown
	value = 25
	min_val = 0

CONFIG_DEF(flag/hub)	// if the game appears on the hub or not

CONFIG_DEF(flag/log_ooc)	// log OOC channel

CONFIG_DEF(flag/log_access)	// log login/logout

CONFIG_DEF(flag/log_say)	// log client say

CONFIG_DEF(flag/log_admin)	// log admin actions
	protection = CONFIG_ENTRY_LOCKED

CONFIG_DEF(flag/log_prayer)	// log prayers

CONFIG_DEF(flag/log_law)	// log lawchanges

CONFIG_DEF(flag/log_game)	// log game events

CONFIG_DEF(flag/log_vote)	// log voting

CONFIG_DEF(flag/log_whisper)	// log client whisper

CONFIG_DEF(flag/log_attack)	// log attack messages

CONFIG_DEF(flag/log_emote)	// log emotes

CONFIG_DEF(flag/log_adminchat)	// log admin chat messages
	protection = CONFIG_ENTRY_LOCKED

CONFIG_DEF(flag/log_pda)	// log pda messages

CONFIG_DEF(flag/log_twitter)	// log certain expliotable parrots and other such fun things in a JSON file of twitter valid phrases.

CONFIG_DEF(flag/log_world_topic)	// log all world.Topic() calls

CONFIG_DEF(flag/log_manifest)	// log crew manifest to seperate file

CONFIG_DEF(flag/allow_admin_ooccolor)	// Allows admins with relevant permissions to have their own ooc colour

CONFIG_DEF(flag/allow_vote_restart)	// allow votes to restart

CONFIG_DEF(flag/allow_vote_mode)	// allow votes to change mode

CONFIG_DEF(number/vote_delay)	// minimum time between voting sessions (deciseconds, 10 minute default)
	value = 6000
	min_val = 0

CONFIG_DEF(number/vote_period)	// length of voting period (deciseconds, default 1 minute)
	value = 600
	min_val = 0

CONFIG_DEF(flag/default_no_vote)	// vote does not default to nochange/norestart

CONFIG_DEF(flag/no_dead_vote)	// dead people can't vote

CONFIG_DEF(flag/allow_metadata)	// Metadata is supported.

CONFIG_DEF(flag/popup_admin_pm)	// adminPMs to non-admins show in a pop-up 'reply' window when set

CONFIG_DEF(number/fps)
	value = 20
	min_val = 1
	max_val = 100   //byond will start crapping out at 50, so this is just ridic
	var/sync_validate = FALSE

/datum/config_entry/number/fps/ValidateAndSet(str_val)
	. = ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/ticklag/TL = config.entries_by_type[/datum/config_entry/number/ticklag]
		if(!TL.sync_validate)
			TL.ValidateAndSet(10 / value)
		sync_validate = FALSE

CONFIG_DEF(number/ticklag)
	integer = FALSE
	var/sync_validate = FALSE

/datum/config_entry/number/ticklag/New()	//ticklag weirdly just mirrors fps
	var/datum/config_entry/CE = /datum/config_entry/number/fps
	value = 10 / initial(CE.value)
	..()

/datum/config_entry/number/ticklag/ValidateAndSet(str_val)
	. = text2num(str_val) > 0 && ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/fps/FPS = config.entries_by_type[/datum/config_entry/number/fps]
		if(!FPS.sync_validate)
			FPS.ValidateAndSet(10 / value)
		sync_validate = FALSE

CONFIG_DEF(flag/allow_holidays)

CONFIG_DEF(number/tick_limit_mc_init)	//SSinitialization throttling
	value = TICK_LIMIT_MC_INIT_DEFAULT
	min_val = 0 //oranges warned us
	integer = FALSE

CONFIG_DEF(flag/admin_legacy_system)	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system
	protection = CONFIG_ENTRY_LOCKED

CONFIG_DEF(string/hostedby)

CONFIG_DEF(flag/norespawn)

CONFIG_DEF(flag/guest_jobban)

CONFIG_DEF(flag/usewhitelist)

CONFIG_DEF(flag/ban_legacy_system)	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system.
	protection = CONFIG_ENTRY_LOCKED

CONFIG_DEF(flag/use_age_restriction_for_jobs)	//Do jobs use account age restrictions? --requires database

CONFIG_DEF(flag/use_account_age_for_jobs)	//Uses the time they made the account for the job restriction stuff. New player joining alerts should be unaffected.

CONFIG_DEF(flag/use_exp_tracking)

CONFIG_DEF(flag/use_exp_restrictions_heads)

CONFIG_DEF(number/use_exp_restrictions_heads_hours)
	value = 0
	min_val = 0

CONFIG_DEF(flag/use_exp_restrictions_heads_department)

CONFIG_DEF(flag/use_exp_restrictions_other)

CONFIG_DEF(flag/use_exp_restrictions_admin_bypass)

CONFIG_DEF(string/server)

CONFIG_DEF(string/banappeals)

CONFIG_DEF(string/wikiurl)
	value = "http://www.tgstation13.org/wiki"

CONFIG_DEF(string/forumurl)
	value = "http://tgstation13.org/phpBB/index.php"

CONFIG_DEF(string/rulesurl)
	value = "http://www.tgstation13.org/wiki/Rules"

CONFIG_DEF(string/githuburl)
	value = "https://www.github.com/tgstation/-tg-station"

CONFIG_DEF(number/githubrepoid)
	value = null
	min_val = 0

CONFIG_DEF(flag/guest_ban)

CONFIG_DEF(number/id_console_jobslot_delay)
	value = 30
	min_val = 0

CONFIG_DEF(number/inactivity_period)	//time in ds until a player is considered inactive)
	value = 3000
	min_val = 0

/datum/config_entry/number/inactivity_period/ValidateAndSet(str_val)
	. = ..()
	if(.)
		value *= 10 //documented as seconds in config.txt

CONFIG_DEF(number/afk_period)	//time in ds until a player is considered inactive)
	value = 3000
	min_val = 0

/datum/config_entry/number/afk_period/ValidateAndSet(str_val)
	. = ..()
	if(.)
		value *= 10 //documented as seconds in config.txt

CONFIG_DEF(flag/kick_inactive)	//force disconnect for inactive players

CONFIG_DEF(flag/load_jobs_from_txt)

CONFIG_DEF(flag/forbid_singulo_possession)

CONFIG_DEF(flag/automute_on)	//enables automuting/spam prevention

CONFIG_DEF(string/panic_server_name)

/datum/config_entry/string/panic_server_name/ValidateAndSet(str_val)
	return str_val != "\[Put the name here\]" && ..()

CONFIG_DEF(string/panic_address)	//Reconnect a player this linked server if this server isn't accepting new players

/datum/config_entry/string/panic_address/ValidateAndSet(str_val)
	return str_val != "byond://address:port" && ..()

CONFIG_DEF(string/invoke_youtubedl)
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

CONFIG_DEF(flag/show_irc_name)

CONFIG_DEF(flag/see_own_notes)	//Can players see their own admin notes (read-only)?

CONFIG_DEF(number/note_fresh_days)
	value = null
	min_val = 0
	integer = FALSE

CONFIG_DEF(number/note_stale_days)
	value = null
	min_val = 0
	integer = FALSE

CONFIG_DEF(flag/maprotation)

CONFIG_DEF(number/maprotatechancedelta)
	value = 0.75
	min_val = 0
	max_val = 1
	integer = FALSE

CONFIG_DEF(number/soft_popcap)
	value = null
	min_val = 0

CONFIG_DEF(number/hard_popcap)
	value = null
	min_val = 0

CONFIG_DEF(number/extreme_popcap)
	value = null
	min_val = 0

CONFIG_DEF(string/soft_popcap_message)
	value = "Be warned that the server is currently serving a high number of users, consider using alternative game servers."

CONFIG_DEF(string/hard_popcap_message)
	value = "The server is currently serving a high number of users, You cannot currently join. You may wait for the number of living crew to decline, observe, or find alternative servers."

CONFIG_DEF(string/extreme_popcap_message)
	value = "The server is currently serving a high number of users, find alternative servers."

CONFIG_DEF(flag/panic_bunker)	// prevents people the server hasn't seen before from connecting

CONFIG_DEF(number/notify_new_player_age)	// how long do we notify admins of a new player
	min_val = -1

CONFIG_DEF(number/notify_new_player_account_age)	// how long do we notify admins of a new byond account
	min_val = 0

CONFIG_DEF(flag/irc_first_connection_alert)	// do we notify the irc channel when somebody is connecting for the first time?

CONFIG_DEF(flag/check_randomizer)

CONFIG_DEF(string/ipintel_email)

/datum/config_entry/string/ipintel_email/ValidateAndSet(str_val)
	return str_val != "ch@nge.me" && ..()

CONFIG_DEF(number/ipintel_rating_bad)
	value = 1
	integer = FALSE
	min_val = 0
	max_val = 1

CONFIG_DEF(number/ipintel_save_good)
	value = 12
	min_val = 0

CONFIG_DEF(number/ipintel_save_bad)
	value = 1
	min_val = 0

CONFIG_DEF(string/ipintel_domain)
	value = "check.getipintel.net"

CONFIG_DEF(flag/aggressive_changelog)

CONFIG_DEF(flag/autoconvert_notes)	//if all connecting player's notes should attempt to be converted to the database
	protection = CONFIG_ENTRY_LOCKED

CONFIG_DEF(flag/allow_webclient)

CONFIG_DEF(flag/webclient_only_byond_members)

CONFIG_DEF(flag/announce_admin_logout)

CONFIG_DEF(flag/announce_admin_login)

CONFIG_DEF(flag/allow_map_voting)

CONFIG_DEF(flag/generate_minimaps)

CONFIG_DEF(number/client_warn_version)
	value = null
	min_val = 500
	max_val = DM_VERSION - 1

CONFIG_DEF(string/client_warn_message)
	value = "Your version of byond may have issues or be blocked from accessing this server in the future."

CONFIG_DEF(number/client_error_version)
	value = null
	min_val = 500
	max_val = DM_VERSION - 1

CONFIG_DEF(string/client_error_message)
	value = "Your version of byond is too old, may have issues, and is blocked from accessing this server."

CONFIG_DEF(number/minute_topic_limit)
	value = null
	min_val = 0

CONFIG_DEF(number/second_topic_limit)
	value = null
	min_val = 0

CONFIG_DEF(number/error_cooldown)	// The "cooldown" time for each occurrence of a unique error)
	value = 600
	min_val = 0

CONFIG_DEF(number/error_limit)	// How many occurrences before the next will silence them
	value = 50

CONFIG_DEF(number/error_silence_time)	// How long a unique error will be silenced for
	value = 6000

CONFIG_DEF(number/error_msg_delay)	// How long to wait between messaging admins about occurrences of a unique error
	value = 50

CONFIG_DEF(flag/irc_announce_new_game)

CONFIG_DEF(flag/debug_admin_hrefs)

CONFIG_DEF(number/mc_tick_rate/base_mc_tick_rate)
	integer = FALSE
	value = 1

CONFIG_DEF(number/mc_tick_rate/high_pop_mc_tick_rate)
	integer = FALSE
	value = 1.1

CONFIG_DEF(number/mc_tick_rate/high_pop_mc_mode_amount)
	value = 65

CONFIG_DEF(number/mc_tick_rate/disable_high_pop_mc_mode_amount)
	value = 60

CONFIG_TWEAK(number/mc_tick_rate)
	abstract_type = /datum/config_entry/number/mc_tick_rate

CONFIG_TWEAK(number/mc_tick_rate/ValidateAndSet(str_val))
	. = ..()
	if (.)
		Master.UpdateTickRate()
