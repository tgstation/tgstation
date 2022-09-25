SUBSYSTEM_DEF(dcbotgonder)
	flags = SS_NO_INIT
	name = "dcbotgonder"
	wait = 15 SECONDS

/datum/controller/subsystem/dcbotgonder/fire(resumed)
	var/totalPlayers
	totalPlayers = LAZYLEN(GLOB.player_list)
	world.Export("http://localhost:22422/[totalPlayers]",1,null)
