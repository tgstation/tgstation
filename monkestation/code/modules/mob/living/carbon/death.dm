/mob/living/carbon/proc/start_rotting()
	if(stat == DEAD && !GetComponent(/datum/component/rot/corpse))
		LoadComponent(/datum/component/rot/corpse)
