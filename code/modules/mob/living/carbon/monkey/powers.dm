/mob/living/carbon/monkey/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Monkey"

	if(contents.len)
		for(var/obj/item/carried_item in contents)//If the monkey got on objects.
			if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
				src << "\red You can't be carrying items or have items equipped when vent crawling!"
				return

	if(!stat)
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
						for(var/mob/O in oviewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("<B>[src] scrambles into the ventillation ducts!</B>"), 1)
						loc = target_vent.loc
				else
					src << "You need to remain still while entering a vent."
			else
				src << "This vent is not connected to anything."
		else
			src << "You must be standing on or beside an air vent to enter it."
	else
		src << "You must be conscious to do this!"
	return