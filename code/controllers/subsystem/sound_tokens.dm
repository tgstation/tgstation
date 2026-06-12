SUBSYSTEM_DEF(sound_tokens)
	name = "Sound Tokens"
	wait = 1
	ss_flags = SS_TICKER | SS_BACKGROUND | SS_NO_INIT


	var/list/clients_needing_update = list()
	var/list/currentrun = list()

/datum/controller/subsystem/sound_tokens/fire(resumed)
	if(!resumed)
		currentrun = clients_needing_update
		clients_needing_update = list()
	while(length(currentrun))
		var/client/client = currentrun[currentrun.len]
		currentrun.len--
		var/mob/owned_mob = client.mob
		if(!owned_mob)
			continue
		for(var/datum/sound_token/token in client.sound_tokens)
			token.update_listener(owned_mob)
		if(MC_TICK_CHECK)
			break

