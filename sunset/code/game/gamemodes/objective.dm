/datum/objective/steal/check_completion()
	. = ..()
	var/list/ok_areas = list(/area/sunset/infiltrator_base, /area/syndicate_mothership, /area/shuttle/sunset/stealthcruiser)
	var/list/compiled_areas = list()
	for(var/A in ok_areas)
		compiled_areas += typesof(A)
	for(var/A in compiled_areas)
		for(var/obj/item/I in get_area_by_type(A)) //Check for items
			if(istype(I, steal_target))
				if(!targetinfo) //If there's no targetinfo, then that means it was a custom objective. At this point, we know you have the item, so return 1.
					return TRUE
				else if(targetinfo.check_special_completion(I))//Returns 1 by default. Items with special checks will return 1 if the conditions are fulfilled.
					return TRUE
			if(targetinfo && (I.type in targetinfo.altitems)) //Ok, so you don't have the item. Do you have an alternative, at least?
				if(targetinfo.check_special_completion(I))//Yeah, we do! Don't return 0 if we don't though - then you could fail if you had 1 item that didn't pass and got checked first!
					return TRUE
			CHECK_TICK
	CHECK_TICK

/datum/objective/give_special_equipment(special_equipment)
	if(istype(team, /datum/team/infiltrator))
		for(var/eq_path in special_equipment)
			if(eq_path)
				for(var/turf/T in GLOB.infiltrator_objective_items)
					if(!(eq_path in T.contents))
						new eq_path(T)
	else
		..()