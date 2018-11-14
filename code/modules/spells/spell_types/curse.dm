/proc/curse_of_madness(mob/user)
	if(user) //in this case either someone holding a spellbook or a badmin
		to_chat(user, "<span class='warning'>You sent a curse of madness!</span>")
		message_admins("[ADMIN_LOOKUPFLW(user)] sent a curse of madness!")
		log_game("[key_name(user)] sent a curse of madness!")

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		var/turf/T = get_turf(H)
		if(T && !is_station_level(T.z))
			continue
		if(H.stat == DEAD)
			continue
		to_chat(H, "<span class='warning'>You feel something twisting your mind...</span>")
		switch(rand(1,10))
			if(1 to 4)
				H.gain_trauma(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
				H.gain_trauma(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
			if(5 to 8)
				H.gain_trauma(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
			if(9 to 10)
				H.gain_trauma(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_LOBOTOMY)