

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

	while(budget > 0 && overall_sanity > 0)
		// Pick a ruin
		var/datum/map_template/ruin/ruin = null
		if(ruins && ruins.len)
			ruin = ruins[pick(ruins)]
		else
			world.log << "Ruin loader had no ruins to pick from with [budget] left to spend."
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
			var/width_border = TRANSITIONEDGE + round(ruin.width / 2)
			var/height_border = TRANSITIONEDGE + round(ruin.height / 2)
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

			world.log << "Ruin \"[ruin.name]\" placed at ([T.x], [T.y], [T.z])"

			var/obj/effect/ruin_loader/R = new /obj/effect/ruin_loader(T)
			R.Load(ruins,ruin)
			budget -= ruin.cost
			if(!ruin.allow_duplicates)
				ruins -= ruin.name
			break

	if(!overall_sanity)
		world.log << "Ruin loader gave up with [budget] left to spend."


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
