/datum/hud/brain

/mob/living/brain/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/brain(src)

