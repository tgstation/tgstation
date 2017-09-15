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
