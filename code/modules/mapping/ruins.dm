

/proc/seedRuins(list/z_levels = null, budget = 0, whitelist = /area/space, list/potentialRuins)
	if(!z_levels || !z_levels.len)
		WARNING("No Z levels provided - Not generating ruins")
		return

	for(var/zl in z_levels)
		var/turf/T = locate(1, 1, zl)
		if(!T)
			WARNING("Z level [zl] does not exist - Not generating ruins")
			return

	var/overall_sanity = 100
	var/list/ruins = potentialRuins.Copy()

	var/is_picking = FALSE
	var/last_checked_ruin_index = 0
	while(budget > 0 && overall_sanity > 0)
		// Pick a ruin
		var/datum/map_template/ruin/ruin = null
		if(ruins && ruins.len)
			last_checked_ruin_index++ //ruins with no cost come first in the ruin list, so they'll get picked really often
			if(is_picking)
				ruin = ruins[pick(ruins)]
			else
				var/ruin_key = ruins[last_checked_ruin_index] //get the ruin's key via index
				ruin = ruins[ruin_key] //use that key to get the ruin datum itself
				if(ruin.cost >= 0) //if it has a non-negative cost, cancel out and pick another, to ensure true randomness
					is_picking = TRUE
					ruin = ruins[pick(ruins)]
		else
			log_world("Ruin loader had no ruins to pick from with [budget] left to spend.")
			break
		// Can we afford it
		if(ruin.cost > budget)
			overall_sanity--
			continue
		// If so, try to place it
		var/sanity = 100
		// And if we can't fit it anywhere, give up, try again

		while(sanity > 0)
			sanity--
			var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(ruin.width / 2)
			var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(ruin.height / 2)
			var/z_level = pick(z_levels)
			var/turf/T = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z_level)
			var/valid = TRUE

			for(var/turf/check in ruin.get_affected_turfs(T,1))
				var/area/new_area = get_area(check)
				if(!(istype(new_area, whitelist)))
					valid = FALSE
					break

			if(!valid)
				continue

			log_world("Ruin \"[ruin.name]\" placed at ([T.x], [T.y], [T.z])")

			var/obj/effect/ruin_loader/R = new /obj/effect/ruin_loader(T)
			R.Load(ruins,ruin)
			if(ruin.cost >= 0)
				budget -= ruin.cost
			if(!ruin.allow_duplicates)
				for(var/m in ruins)
					var/datum/map_template/ruin/ruin_to_remove = ruins[m]
					if(ruin_to_remove.id == ruin.id) //remove all ruins with the same ID, to make sure that ruins with multiple variants work properly
						ruins -= ruin_to_remove.name
						last_checked_ruin_index--
			break

	if(!overall_sanity)
		log_world("Ruin loader gave up with [budget] left to spend.")


/obj/effect/ruin_loader
	name = "random ruin"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	invisibility = 0

/obj/effect/ruin_loader/proc/Load(list/potentialRuins, datum/map_template/template)
	var/list/possible_ruins = list()
	for(var/A in potentialRuins)
		var/datum/map_template/T = potentialRuins[A]
		if(!T.loaded)
			possible_ruins += T
	if(!template && possible_ruins.len)
		template = safepick(possible_ruins)
	if(!template)
		return FALSE
	var/turf/central_turf = get_turf(src)
	for(var/i in template.get_affected_turfs(central_turf, 1))
		var/turf/T = i
		for(var/mob/living/simple_animal/monster in T)
			qdel(monster)
		for(var/obj/structure/flora/ash/plant in T)
			qdel(plant)
	template.load(central_turf,centered = TRUE)
	template.loaded++
	var/datum/map_template/ruin = template
	if(istype(ruin))
		new /obj/effect/landmark/ruin(central_turf, ruin)

	qdel(src)
	return TRUE
