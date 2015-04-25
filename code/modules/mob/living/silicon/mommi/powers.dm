/mob/living/silicon/robot/mommi/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Robot Commands"
	var/mob/living/silicon/robot/mommi/R = src
	var/atom/pipe
	var/list/pipes = list()
	for(var/obj/machinery/atmospherics/unary/U in view(1))
		if((istype(U, /obj/machinery/atmospherics/unary/vent_pump) || istype(U,/obj/machinery/atmospherics/unary/vent_scrubber)) && Adjacent(U))
			pipes |= U
	if(!pipes || !pipes.len)
		return
	if(pipes.len == 1)
		pipe = pipes[1]
	else
		pipe = input("Crawl Through Vent", "Pick a pipe") as null|anything in pipes
	if(R.canmove && pipe)
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
		src << text("<span class='notice'>You are now hiding.</span>")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << "<B>[src] tries to hide itself!</B>"
	else
		layer = MOB_LAYER
		src << text("<span class='notice'>You have stopped hiding.</span>")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << "[src] slowly peeks up..."
	updateicon()

/mob/living/silicon/robot/mommi/verb/park()
	set name = "Toggle Parking Brake"
	set desc = "Lock yourself in place"
	set category = "Robot Commands"
	var/mob/living/silicon/robot/mommi/R = src
	R.anchored=!R.anchored
	R.canmove=!R.anchored
	updateicon()