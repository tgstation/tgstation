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
			
CONFIG_DEF(/datum/config_entry/flag/vote_no_default)	// vote does not default to nochange/norestart

CONFIG_DEF(/datum/config_entry/flag/vote_no_dead)	// dead people can't vote (tbi)

CONFIG_DEF(/datum/config_entry/flag/allow_Metadata)	// Metadata is supported.

CONFIG_DEF(/datum/config_entry/flag/popup_admin_pm)	// adminPMs to non-admins show in a pop-up 'reply' window when set

CONFIG_DEF(/datum/config_entry/number/clamped/fps)
	value = 20
	min_val = 1
	max_val = 100   //byond will start crapping out at 50, so this is just ridic

CONFIG_DEF(/datum/config_entry/flag/allow_holidays)

CONFIG_DEF(/datum/config_entry/number/clamped/tick_limit_mc_init)	//SSinitialization throttling
	value = TICK_LIMIT_MC_INIT_DEFAULT
	min_val = 0 //oranges warned us
