/datum/map_template/ruin/proc/try_to_place(z, list/allowed_areas_typecache, turf/forced_turf, clear_below)
	var/sanity = forced_turf ? 1 : PLACEMENT_TRIES
	if(SSmapping.level_trait(z,ZTRAIT_ISOLATED_RUINS))
		return place_on_isolated_level(z)
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = forced_turf ? forced_turf : locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE
		var/list/affected_turfs = get_affected_turfs(central_turf,1)
		var/list/affected_areas = list()

		for(var/turf/check in affected_turfs)
			// Use assoc lists to move this out, it's easier that way
			if(check.turf_flags & NO_RUINS)
				valid = FALSE // set to false before we check
				break
			var/area/new_area = get_area(check)
			affected_areas[new_area] = TRUE

		// This is faster yes. Only BARELY but it is faster
		for(var/area/affct_area as anything in affected_areas)
			if(!allowed_areas_typecache[affct_area.type])
				valid = FALSE
				break

		if(!valid)
			continue

		testing("Ruin \"[name]\" placed at ([central_turf.x], [central_turf.y], [central_turf.z])")

		if(clear_below)
			var/static/list/clear_below_typecache = typecacheof(list(
				/obj/structure/spawner,
				/mob/living/simple_animal,
				/obj/structure/flora
			))
			for(var/turf/T as anything in affected_turfs)
				for(var/atom/thing as anything in T)
					if(clear_below_typecache[thing.type])
						qdel(thing)

		load(central_turf,centered = TRUE)
		loaded++

		for(var/turf/T in affected_turfs)
			T.turf_flags |= NO_RUINS

		new /obj/effect/landmark/ruin(central_turf, src)
		return central_turf

/datum/map_template/ruin/proc/place_on_isolated_level(z)
	var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(width, height, 1, z) //Make the new level creation work with different traits.
	if(!reservation)
		return
	var/turf/placement = reservation.bottom_left_turfs[1]
	load(placement)
	loaded++
	for(var/turf/T in get_affected_turfs(placement))
		T.turf_flags |= NO_RUINS
	var/turf/center = locate(placement.x + round(width/2),placement.y + round(height/2),placement.z)
	new /obj/effect/landmark/ruin(center, src)
	return center

/**
 * Loads the ruins for a given z level.
 * @param z_levels The z levels to load ruins on.
 * @param budget The budget to spend on ruins. Compare against the cost of the ruins in /datum/map_template/ruin.
 * @param whitelist A list of areas to allow ruins to be placed in.
 * @param potentialRuins A list of ruins to choose from.
 * @param clear_below Whether to clear the area below the ruin. Used for multiz ruins.
 * @param mineral_budget The budget to spend on ruins that spawn ore vents. Map templates with vents have that defined by mineral_cost.
 * @param mineral_budget_update What type of ore distribution should spawn from ruins picked by this cave generator? This list is copied from ores_spawned.dm into SSore_generation.ore_vent_minerals.
 */
/proc/seedRuins(list/z_levels = null, budget = 0, whitelist = list(/area/space), list/potentialRuins, clear_below = FALSE, mineral_budget = 15, mineral_budget_update)
	if(!z_levels || !z_levels.len)
		WARNING("No Z levels provided - Not generating ruins")
		return
	var/list/whitelist_typecache = typecacheof(whitelist)

	for(var/zl in z_levels)
		var/turf/T = locate(1, 1, zl)
		if(!T)
			WARNING("Z level [zl] does not exist - Not generating ruins")
			return

	var/list/ruins = potentialRuins.Copy()

	var/list/forced_ruins = list() //These go first on the z level associated (same random one by default) or if the assoc value is a turf to the specified turf.
	var/list/ruins_available = list() //we can try these in the current pass

	if(PERFORM_ALL_TESTS(log_mapping))
		log_mapping("All ruins being loaded for map testing.")

	switch(mineral_budget_update) //If we use more map configurations, add another case
		if(OREGEN_PRESET_LAVALAND)
			SSore_generation.ore_vent_minerals = expand_weights(GLOB.ore_vent_minerals_lavaland)
		if(OREGEN_PRESET_TRIPLE_Z)
			SSore_generation.ore_vent_minerals = expand_weights(GLOB.ore_vent_minerals_triple_z)

	//Set up the starting ruin list
	for(var/key in ruins)
		var/datum/map_template/ruin/R = ruins[key]

		if(PERFORM_ALL_TESTS(log_mapping))
			R.cost = 0
			R.allow_duplicates = FALSE // no multiples for testing
			R.always_place = !R.unpickable // unpickable ruin means it spawns as a set with another ruin

		if(R.cost > budget || R.mineral_cost > mineral_budget) //Why would you do that
			continue
		if(R.always_place)
			forced_ruins[R] = -1
		if(R.unpickable)
			continue
		ruins_available[R] = R.placement_weight
	while(((budget > 0 || mineral_budget > 0) && ruins_available.len) || forced_ruins.len)
		var/datum/map_template/ruin/current_pick
		var/forced = FALSE
		var/forced_z //If set we won't pick z level and use this one instead.
		var/forced_turf //If set we place the ruin centered on the given turf
		if(forced_ruins.len) //We have something we need to load right now, so just pick it
			for(var/ruin in forced_ruins)
				current_pick = ruin
				if(isturf(forced_ruins[ruin]))
					var/turf/T = forced_ruins[ruin]
					forced_z = T.z //In case of chained ruins
					forced_turf = T
				else if(forced_ruins[ruin] > 0) //Load into designated z
					forced_z = forced_ruins[ruin]
				forced = TRUE
				break
		else //Otherwise just pick random one
			current_pick = pick_weight(ruins_available)

		var/placement_tries = forced_turf ? 1 : PLACEMENT_TRIES //Only try once if we target specific turf
		var/failed_to_place = TRUE
		var/target_z = 0
		var/turf/placed_turf //Where the ruin ended up if we succeeded
		outer:
			while(placement_tries > 0)
				placement_tries--
				target_z = pick(z_levels)
				if(forced_z)
					target_z = forced_z
				if(current_pick.always_spawn_with) //If the ruin has part below, make sure that z exists.
					for(var/v in current_pick.always_spawn_with)
						if(current_pick.always_spawn_with[v] == PLACE_BELOW)
							var/turf/T = locate(1,1,target_z)
							if(!GET_TURF_BELOW(T))
								if(forced_z)
									continue outer
								else
									break outer

				placed_turf = current_pick.try_to_place(target_z,whitelist_typecache,forced_turf,clear_below)
				if(!placed_turf)
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
			for(var/datum/map_template/ruin/R in ruins_available)
				if(R.id == current_pick.id)
					ruins_available -= R
			log_world("Failed to place [current_pick.name] ruin.")
		else
			budget -= current_pick.cost
			mineral_budget -= current_pick.mineral_cost
			if(!current_pick.allow_duplicates)
				for(var/datum/map_template/ruin/R in ruins_available)
					if(R.id == current_pick.id)
						ruins_available -= R
			if(current_pick.never_spawn_with)
				for(var/blacklisted_type in current_pick.never_spawn_with)
					for(var/possible_exclusion in ruins_available)
						if(istype(possible_exclusion,blacklisted_type))
							ruins_available -= possible_exclusion
			if(current_pick.always_spawn_with)
				for(var/v in current_pick.always_spawn_with)
					for(var/ruin_name in SSmapping.ruins_templates) //Because we might want to add space templates as linked of lava templates.
						var/datum/map_template/ruin/linked = SSmapping.ruins_templates[ruin_name] //why are these assoc, very annoying.
						if(istype(linked,v))
							switch(current_pick.always_spawn_with[v])
								if(PLACE_SAME_Z)
									forced_ruins[linked] = target_z //I guess you might want a chain somehow
								if(PLACE_LAVA_RUIN)
									forced_ruins[linked] = pick(SSmapping.levels_by_trait(ZTRAIT_LAVA_RUINS))
								if(PLACE_SPACE_RUIN)
									forced_ruins[linked] = pick(SSmapping.levels_by_trait(ZTRAIT_SPACE_RUINS))
								if(PLACE_DEFAULT)
									forced_ruins[linked] = -1
								if(PLACE_BELOW)
									forced_ruins[linked] = GET_TURF_BELOW(placed_turf)
								if(PLACE_ISOLATED)
									forced_ruins[linked] = SSmapping.get_isolated_ruin_z()

		//Update the available list
		for(var/datum/map_template/ruin/R in ruins_available)
			if(R.cost > budget || R.mineral_cost > mineral_budget)
				ruins_available -= R

	log_world("Ruin loader finished with [budget] left to spend.")
