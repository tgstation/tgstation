<<<<<<< HEAD
/datum/game_mode/sandbox
	name = "sandbox"
	config_tag = "sandbox"
	required_players = 0

	announce_span = "info"
	announce_text = "Build your own station... or just shoot each other!"

/datum/game_mode/sandbox/pre_setup()
	for(var/mob/M in player_list)
		M.CanBuild()
	return 1

/datum/game_mode/sandbox/post_setup()
	..()
	SSshuttle.registerHostileEnvironment(src)
=======
/datum/game_mode/sandbox
	name = "sandbox"
	config_tag = "sandbox"
	required_players = 0

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

/datum/game_mode/sandbox/announce()
	to_chat(world, "<B>The current game mode is - Sandbox!</B>")
	to_chat(world, "<B>Build your own station with the sandbox-panel command!</B>")

/datum/game_mode/sandbox/pre_setup()
	log_admin("Starting a round of sandbox.")
	message_admins("Starting a round of sandbox.")
	return 1

/datum/game_mode/sandbox/post_setup()
	..()
	for(var/mob/M in player_list)
		M.CanBuild()
	//if(emergency_shuttle)
	//	emergency_shuttle.always_fake_recall = 1

/datum/game_mode/sandbox/latespawn(var/mob/mob)
	mob.CanBuild()
	to_chat(mob, "<B>Build your own station with the sandbox-panel command!</B>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
