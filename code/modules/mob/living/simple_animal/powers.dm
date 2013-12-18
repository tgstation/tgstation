/mob/living/simple_animal/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Animal"

	if(stat != CONSCIOUS)
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\green You are now hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scurries to the ground!</B>", src)
	else
		layer = MOB_LAYER
		src << text("\green You have stopped hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("[] slowly peaks up from the ground...", src)