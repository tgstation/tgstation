/datum/game_mode/sandbox
	name = "sandbox"
	config_tag = "sandbox"
	required_players = 0

/datum/game_mode/sandbox/announce()
	world << "<B>The current game mode is - Sandbox!</B>"
	world << "<B>Build your own station with the sandbox-panel command!</B>"

/datum/game_mode/sandbox/pre_setup()
	for(var/mob/M in player_list)
		M.CanBuild()
	return 1

/datum/game_mode/sandbox/post_setup()
	..()
	SSshuttle.emergencyNoEscape = 1
