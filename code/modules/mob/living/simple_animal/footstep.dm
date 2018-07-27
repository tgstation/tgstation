/mob/living/simple_animal
	var/do_footstep = FALSE

/mob/living/simple_animal/get_footstep_modifiers()
	if(!do_footstep)
		return null
	return ..()