/mob/living/silicon/robot/mommi/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Robot Commands"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


/mob/living/silicon/robot/mommi/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Robot Commands"

	if(stat != CONSCIOUS)
		return
	var/mob/living/silicon/robot/mommi/R = src
	if(!R.canmove)
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, "<B>[src] tries to hide itself!</B>")
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, "[src] slowly peeks up...")
	updateicon()

/mob/living/silicon/robot/mommi/verb/park()
	set name = "Toggle Parking Brake"
	set desc = "Lock yourself in place"
	set category = "Robot Commands"
	var/mob/living/silicon/robot/mommi/R = src
	R.anchored=!R.anchored
	R.canmove=!R.anchored
	updateicon()