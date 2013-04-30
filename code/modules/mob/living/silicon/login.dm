/mob/living/silicon/Login()
	if(mind && ticker && ticker.mode)
		ticker.mode.remove_cultist(mind, 1)
		ticker.mode.remove_revolutionary(mind, 1)

	verbs -= /mob/living/verb/lay_down
	verbs -= /mob/living/verb/mob_sleep

	..()