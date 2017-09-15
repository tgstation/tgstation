/datum/config_entry/flag/autoadmin  // if autoadmin is enabled
    resident_file = CONFIG_GENERAL

/datum/config_entry/string/autoadmin_rank   // the rank for autoadmins
    resident_file = CONFIG_GENERAL
    value = "Game Master"

/datum/config_entry/string/servername   // server name (the name of the game window)
    resident_file = CONFIG_GENERAL

/datum/config_entry/string/serversqlname    // short form server name used for the DB
    resident_file = CONFIG_GENERAL

/datum/config_entry/string/stationname  // station name (the name of the station in-game)
    resident_file = CONFIG_GENERAL

/datum/config_entry/number/clamped/lobby_countdown  // In between round countdown.
    resident_file = CONFIG_GENERAL
    value = 120
    min = 0

/datum/config_entry/number/clamped/lobby_countdown  // Post round murder death kill countdown
    resident_file = CONFIG_GENERAL
    value = 25
    min = 0

/datum/config_entry/flag/hub    // if the game appears on the hub or not
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_ooc    // log OOC channel
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_access // log login/logout
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_say    // log client say
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_admin  // log admin actions
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_prayer // log prayers
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_law    // log lawchanges
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_game   // log game events
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_vote   // log voting
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_whisper    // log client whisper
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_attack // log attack messages
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_emote  // log emotes
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_adminchat  // log admin chat messages
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_pda    // log pda messages
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_twitter    // log certain expliotable parrots and other such fun things in a JSON file of twitter valid phrases.
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/log_world_topic    // log all world.Topic() calls
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/sql_enabled    // for sql switching
    resident_file = CONFIG_DATABASE
    protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/flag/allow_admin_ooccolor   // Allows admins with relevant permissions to have their own ooc colour
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/allow_vote_restart // allow votes to restart
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/allow_vote_mode    // allow votes to change mode
    resident_file = CONFIG_GENERAL

/datum/config_entry/number/clamped/vote_delay   // minimum time between voting sessions (deciseconds, 10 minute default)
    resident_file = CONFIG_GENERAL
    value = 6000
    min = 0

/datum/config_entry/number/clamped/vote_period  // length of voting period (deciseconds, default 1 minute)
    resident_file = CONFIG_GENERAL
    value = 600
    min = 0
			
/datum/config_entry/flag/vote_no_default    // vote does not default to nochange/norestart
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/vote_no_dead   // dead people can't vote (tbi)
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/allow_Metadata // Metadata is supported.
    resident_file = CONFIG_GENERAL

/datum/config_entry/flag/popup_admin_pm // adminPMs to non-admins show in a pop-up 'reply' window when set
    resident_file = CONFIG_GENERAL

/datum/config_entry/number/clamped/fps
    resident_file = CONFIG_GENERAL
    value = 20
    min = 1
    max = 100   //byond will start crapping out at 50, so this is just ridic

/datum/config_entry/flag/allow_holidays
    resident_file = CONFIG_GENERAL

/datum/config_entry/number/clamped/tick_limit_mc_init	//SSinitialization throttling
    value = TICK_LIMIT_MC_INIT_DEFAULT
    min = 0 //oranges warned us
