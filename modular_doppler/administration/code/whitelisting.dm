SUBSYSTEM_DEF(whitelisting)
	name = "Auto-Whitelist"
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_LOBBY | RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 5 MINUTES

/datum/controller/subsystem/whitelisting/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/whitelisting/fire(resumed = FALSE)
	load_whitelist() // yep that's it
