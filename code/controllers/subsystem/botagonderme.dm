SUBSYSTEM_DEF(dcbotgonder)
    name = "dcbotgonder"
    wait = 15 SECONDS

var/totalPlayers
var/listeof

/datum/controller/subsystem/dcbotgonder/fire(resumed)
    listeof = list(GLOB.player_list)
    totalPlayers = LAZYLEN(GLOB.player_list)
    world.Export("http://localhost:22422/[totalPlayers]",1,null)
