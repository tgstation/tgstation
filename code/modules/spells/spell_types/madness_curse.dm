GLOBAL_VAR_INIT(curse_of_madness_triggered, FALSE)

/proc/curse_of_madness(mob/user, message)
	if(user) //in this case either someone holding a spellbook or a badmin
		to_chat(user, span_warning("You sent a curse of madness with the message \"[message]\"!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] sent a curse of madness with the message \"[message]\"!")
		user.log_message("sent a curse of madness with the message \"[message]\"!", LOG_GAME)

	GLOB.curse_of_madness_triggered = message // So latejoiners are also afflicted.

	deadchat_broadcast("A [span_name("Curse of Madness")] has stricken the station, shattering their minds with the awful secret: \"<span class='big hypnophrase'>[message]</span>\"", message_type=DEADCHAT_ANNOUNCEMENT)

	for(var/mob/living/carbon/human/to_curse in GLOB.player_list)
		if(to_curse.stat == DEAD)
			continue
		var/turf/curse_turf = get_turf(to_curse)
		if(curse_turf && !is_station_level(curse_turf.z))
			continue
		if(to_curse.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
			to_chat(to_curse, span_notice("You have a strange feeling for a moment, but then it passes."))
			continue
		give_madness(to_curse, message)

/proc/give_madness(mob/living/carbon/human/to_curse, message)
	to_curse.playsound_local(get_turf(to_curse), 'sound/magic/curse.ogg', 40, 1)
	to_chat(to_curse, span_reallybig(span_hypnophrase(message)))
	to_chat(to_curse, span_warning("Your mind shatters!"))
	switch(rand(1, 10))
		if(1 to 3)
			to_curse.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
			to_curse.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
		if(4 to 6)
			to_curse.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
		if(7 to 8)
			to_curse.gain_trauma_type(BRAIN_TRAUMA_MAGIC, TRAUMA_RESILIENCE_LOBOTOMY)
		if(9 to 10)
			to_curse.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_LOBOTOMY)
