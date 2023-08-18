/mob/living/simple_animal/hostile/asteroid/ice_demon/random/Initialize()
	. = ..()
	if(prob(15))
		new /mob/living/simple_animal/hostile/asteroid/(loc)
		return INITIALIZE_HINT_QDEL
