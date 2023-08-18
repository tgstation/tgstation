/mob/living/simple_animal/hostile/asteroid/polarbear/random/Initialize()
	. = ..()
	if(prob(15))
		//new /mob/living/simple_animal/hostile/asteroid/polarbear/warrior(loc)
		return INITIALIZE_HINT_QDEL
