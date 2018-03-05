/mob/living/carbon/human/grabbedby(mob/living/user, supress_message = 0)
	if (checkbuttinspect(user))
		return FALSE
	
	return ..()