/proc/KillEveryoneOnZLevel(level)
	if(!level)
		return
	for(var/mob/living/M in GLOB.mob_living_list)
		if(M.loc.z == level)
			M.flash_act(100, TRUE, TRUE)
			to_chat(M, "<span class='userdanger'>You feel your skin prickle with heat as you're ripped atom from atom in the raging inferno of a nuclear blast. Your last thought is 'Oh fuck.'</span>")
			M.emote("scream")
			M.gib()
