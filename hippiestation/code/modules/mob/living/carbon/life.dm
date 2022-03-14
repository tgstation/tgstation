/mob/living/carbon/Life()   //hippie start, passive healing
	. = ..()
	if(passiveHeal)
		passiveFleshHeal()
