/mob/living/carbon/alien/larva/verb/ventcrawl() // -- TLE
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and appear at a random one."
	set category = "Alien"
//	if(!istype(V,/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent))
//		return
	var/vent_found = 0
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
		vent_found = 1
	if(!vent_found)
		src << "You must be standing on or beside an air vent to enter it."
		return
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc == src.loc)
			continue
		vents.Add(temp_vent)
	var/list/choices = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent in vents)
		if(vent.loc.z != src.loc.z)
			continue
		var/atom/a = get_turf_loc(vent)
		choices.Add(a.loc)
	var/obj/selection = input("Select a destination.", "Duct System") in choices
	var/selection_position = choices.Find(selection)
	var/obj/target_vent = vents[selection_position]
	if(target_vent)
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scrambles into the ventillation ducts!</B>", src)
		src.loc = target_vent.loc

/mob/living/carbon/alien/larva/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if (src.layer != TURF_LAYER)
		src.layer = TURF_LAYER
		src << text("\green You are now hiding.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scurries to the ground!</B>", src)
	else
		src.layer = MOB_LAYER
		src << text("\green You have stopped hiding.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("[] slowly peaks up from the ground...", src)