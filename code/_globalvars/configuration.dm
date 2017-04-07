GLOBAL_REAL(config, /datum/configuration)

GLOBAL_DATUM_INIT(revdata, /datum/getrev, new)

GLOBAL_VAR(host)
GLOBAL_VAR(join_motd)
GLOBAL_VAR(station_name)
GLOBAL_VAR_INIT(game_version, "/tg/ Station 13")
GLOBAL_VAR_INIT(changelog_hash, "")

GLOBAL_VAR_INIT(ooc_allowed, TRUE)	// used with admin verbs to disable ooc - not a config option apparently
GLOBAL_VAR_INIT(dooc_allowed, TRUE)
GLOBAL_VAR_INIT(abandon_allowed, TRUE)
GLOBAL_VAR_INIT(enter_allowed, TRUE)
GLOBAL_VAR_INIT(guests_allowed, TRUE)
GLOBAL_VAR_INIT(shuttle_frozen, FALSE)
GLOBAL_VAR_INIT(shuttle_left, FALSE)
GLOBAL_VAR_INIT(tinted_weldhelh, TRUE)


// Debug is used exactly once (in living.dm) but is commented out in a lot of places.  It is not set anywhere and only checked.
// Debug2 is used in conjunction with a lot of admin verbs and therefore is actually legit.
GLOBAL_VAR_INIT(Debug, FALSE)	// global debug switch
GLOBAL_VAR_INIT(Debug2, FALSE)

//Server API key
GLOBAL_VAR_INIT(comms_key, "default_pwd")
GLOBAL_PROTECT(comms_key)
GLOBAL_VAR_INIT(comms_allowed, FALSE) //By default, the server does not allow messages to be sent to it, unless the key is strong enough (this is to prevent misconfigured servers from becoming vulnerable)
GLOBAL_PROTECT(comms_allowed)

GLOBAL_VAR(medal_hub)
GLOBAL_PROTECT(medal_hub)
GLOBAL_VAR_INIT(medal_pass, " ")
GLOBAL_PROTECT(medal_pass)
GLOBAL_VAR_INIT(medals_enabled, TRUE)	//will be auto set to false if the game fails contacting the medal hub to prevent unneeded calls.
GLOBAL_PROTECT(medals_enabled)


//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
GLOBAL_VAR_INIT(MAX_EX_DEVESTATION_RANGE, 3)
GLOBAL_VAR_INIT(MAX_EX_HEAVY_RANGE, 7)
GLOBAL_VAR_INIT(MAX_EX_LIGHT_RANGE, 14)
GLOBAL_VAR_INIT(MAX_EX_FLASH_RANGE, 14)
GLOBAL_VAR_INIT(MAX_EX_FLAME_RANGE, 14)
GLOBAL_VAR_INIT(DYN_EX_SCALE, 0.5)

