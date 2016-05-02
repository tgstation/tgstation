
/datum/hud/revenant/New(mob/owner)
	..()

	healths = new /obj/screen/healths/revenant()
	infodisplay += healths

/mob/living/simple_animal/revenant/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/revenant(src)
