SUBSYSTEM_DEF(sound_tokens)
	name = "Sound Tokens"
	wait = 1
	ss_flags = SS_TICKER | SS_BACKGROUND | SS_NO_INIT

	var/list/playing_sound_tokens = list()

	var/list/clients_needing_update = list()

/datum/controller/subsystem/sound_tokens/fire(resumed)
	for(var/client/client in clients_needing_update)
		clients_needing_update -= client
		var/mob/owned_mob = client.mob
		if(!owned_mob)
			continue
		for(var/datum/sound_token/current_token in playing_sound_tokens)
			current_token.add_or_update_listener(owned_mob)
			CHECK_TICK //Need to see if this causes issues

