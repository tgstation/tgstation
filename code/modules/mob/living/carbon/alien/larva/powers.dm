/mob/living/carbon/alien/larva/verb/ventcrawl() // -- TLE
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"

//	if(!istype(V,/obj/machinery/atmoalter/siphs/fullairsiphon/air_vent))
//		return
	if(powerc())
		var/obj/machinery/atmospherics/unary/vent_pump/vent_found
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
			if(!v.welded)
				vent_found = v
			else
				src << "\red That vent is welded."
		if(vent_found)
			if(vent_found.network&&vent_found.network.normal_members.len)
				var/list/vents = list()
				for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in vent_found.network.normal_members)
					if(temp_vent.loc == loc)
						continue
					vents.Add(temp_vent)
				var/list/choices = list()
				for(var/obj/machinery/atmospherics/unary/vent_pump/vent in vents)
					if(vent.loc.z != loc.z)
						continue
					var/atom/a = get_turf_loc(vent)
					choices.Add(a.loc)
				var/turf/startloc = loc
				var/obj/selection = input("Select a destination.", "Duct System") in choices
				var/selection_position = choices.Find(selection)
				if(loc==startloc)
					var/obj/target_vent = vents[selection_position]
					if(target_vent)
						for(var/mob/O in oviewers())
							if ((O.client && !( O.blinded )))
								O.show_message(text("<B>[src] scrambles into the ventillation ducts!</B>"), 1)
						loc = target_vent.loc
				else
					src << "\green You need to remain still while entering a vent."
			else
				src << "\green This vent is not connected to anything."
		else
			src << "\green You must be standing on or beside an air vent to enter it."
	return

/mob/living/carbon/alien/larva/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Alien"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\green You are now hiding.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scurries to the ground!</B>", src)
	else
		layer = MOB_LAYER
		src << text("\green You have stopped hiding.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("[] slowly peaks up from the ground...", src)