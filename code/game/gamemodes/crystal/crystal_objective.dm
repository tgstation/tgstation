
// Objectives for the crystal mode.

/datum/objective/crystal_steal

	var/steal_amount = 2

	find_target()
		explanation_text = "Smuggle aboard [steal_amount] alien crystals to Central Command via the Escape Shuttle. There are other zealots with their own crystals, steal theirs to get more crystals."

	check_completion()
		if(!owner.current)	return 0
		if(!isliving(owner.current))	return 0
		var/list/all_items = owner.current.GetAllContents()	//this should get things in cheesewheels, books, etc.

		var/crystals = 0

		var/turf/location = get_turf(owner.current.loc)
		if(!location)
			return 0

		if(istype(location, /turf/simulated/shuttle/floor4))
			return 0

		var/area/check_area = location.loc
		if(istype(check_area, /area/shuttle/escape/centcom))
			for(var/obj/I in all_items) //Check for items
				if(istype(I, /obj/item/crystal))
					crystals += 1
			if(crystals >= steal_amount)
				return 1
		return 0