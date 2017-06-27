/datum/game_mode/sandbox
	name = "sandbox"
	config_tag = "sandbox"
	required_players = 0

	announce_span = "info"
	announce_text = "Build your own station... or just shoot each other!"
	
	allow_persistence_save = FALSE

/datum/game_mode/sandbox/pre_setup()
	for(var/mob/M in GLOB.player_list)
		M.CanBuild()
	return 1

/datum/game_mode/sandbox/post_setup()
	..()
	SSshuttle.registerHostileEnvironment(src)
