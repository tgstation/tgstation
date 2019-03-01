/datum/map_template/ruin/proc/try_to_place(z,allowed_areas)
	var/sanity = PLACEMENT_TRIES
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE

		for(var/turf/check in get_affected_turfs(central_turf,1))
			var/area/new_area = get_area(check)
			if(!(istype(new_area, allowed_areas)) || check.flags_1 & NO_RUINS_1)
				valid = FALSE
				break

		if(!valid)
			continue

		testing("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		for(var/i in get_affected_turfs(central_turf, 1))
			var/turf/T = i
			for(var/mob/living/simple_animal/monster in T)
				qdel(monster)
			for(var/obj/structure/flora/ash/plant in T)
				qdel(plant)

		load(central_turf,centered = TRUE)
		loaded++

		for(var/turf/T in get_affected_turfs(central_turf, 1))
			T.flags_1 |= NO_RUINS_1

		new /obj/effect/landmark/ruin(central_turf, src)
		return TRUE
	return FALSE


/proc/seedRuins(list/z_levels = null, budget = 0, whitelist = /area/space, list/potentialRuins)
	if(!z_levels || !z_levels.len)
		WARNING("No Z levels provided - Not generating ruins")
		return

	for(var/zl in z_levels)
		var/turf/T = locate(1, 1, zl)
		if(!T)
			WARNING("Z level [zl] does not exist - Not generating ruins")
			return

	var/list/ruins = potentialRuins.Copy()

	var/list/forced_ruins = list()		//These go first on the z level associated (same random one by default)
	var/list/ruins_availible = list()	//we can try these in the current pass
	var/forced_z	//If set we won't pick z level and use this one instead.

	//Set up the starting ruin list
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]
		if(R.cost > budget) //Why would you do that
			continue
		if(R.always_place)
			forced_ruins[R] = -1
		if(R.unpickable)
			continue
		ruins_availible[R] = R.placement_weight

	while(budget > 0 && (ruins_availible.len || forced_ruins.len))
		var/datum/map_template/ruin/current_pick
		var/forced = FALSE
		if(forced_ruins.len) //We have something we need to load right now, so just pick it
			for(var/ruin in forced_ruins)
				current_pick = ruin
				if(forced_ruins[ruin] > 0) //Load into designated z
					forced_z = forced_ruins[ruin]
				forced = TRUE
				break
		else //Otherwise just pick random one
			current_pick = pickweight(ruins_availible)

		var/placement_tries = PLACEMENT_TRIES
		var/failed_to_place = TRUE
		var/z_placed = 0
		while(placement_tries > 0)
			placement_tries--
			z_placed = pick(z_levels)
			if(!current_pick.try_to_place(forced_z ? forced_z : z_placed,whitelist))
				continue
			else
				failed_to_place = FALSE
				break

		//That's done remove from priority even if it failed
		if(forced)
			//TODO : handle forced ruins with multiple variants
			forced_ruins -= current_pick
			forced = FALSE

		if(failed_to_place)
			for(var/datum/map_template/ruin/R in ruins_availible)
				if(R.id == current_pick.id)
					ruins_availible -= R
			log_world("Failed to place [current_pick.name] ruin.")
		else
			budget -= current_pick.cost
			if(!current_pick.allow_duplicates)
				for(var/datum/map_template/ruin/R in ruins_availible)
					if(R.id == current_pick.id)
						ruins_availible -= R
			if(current_pick.never_spawn_with)
				for(var/blacklisted_type in current_pick.never_spawn_with)
					for(var/possible_exclusion in ruins_availible)
						if(istype(possible_exclusion,blacklisted_type))
							ruins_availible -= possible_exclusion
			if(current_pick.always_spawn_with)
				for(var/v in current_pick.always_spawn_with)
					for(var/ruin_name in SSmapping.ruins_templates) //Because we might want to add space templates as linked of lava templates.
						var/datum/map_template/ruin/linked = SSmapping.ruins_templates[ruin_name] //why are these assoc, very annoying.
						if(istype(linked,v))
							switch(current_pick.always_spawn_with[v])
								if(PLACE_SAME_Z)
									forced_ruins[linked] = forced_z ? forced_z : z_placed //I guess you might want a chain somehow
								if(PLACE_LAVA_RUIN)
									forced_ruins[linked] = pick(SSmapping.levels_by_trait(ZTRAIT_LAVA_RUINS))
								if(PLACE_EARTH_RUIN)
									forced_ruins[linked] = pick(SSmapping.levels_by_trait(ZTRAIT_EARTH_RUINS))
								if(PLACE_SPACE_RUIN)
									forced_ruins[linked] = pick(SSmapping.levels_by_trait(ZTRAIT_SPACE_RUINS))
								if(PLACE_DEFAULT)
									forced_ruins[linked] = -1
		forced_z = 0

		//Update the availible list
		for(var/datum/map_template/ruin/R in ruins_availible)
			if(R.cost > budget)
				ruins_availible -= R

	log_world("Ruin loader finished with [budget] left to spend.")
