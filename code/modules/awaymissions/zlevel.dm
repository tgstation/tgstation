// How much "space" we give the edge of the map
var/global/list/potentialRandomZlevels = generateMapList(filename = "config/awaymissionconfig.txt")

/proc/createRandomZlevel()
	if(awaydestinations.len)	//crude, but it saves another var!
		return

	if(potentialRandomZlevels && potentialRandomZlevels.len)
		world << "<span class='boldannounce'>Loading away mission...</span>"

		var/map = pick(potentialRandomZlevels)
		var/file = file(map)
		if(isfile(file))
			maploader.load_map(file)
			smooth_zlevel(world.maxz)
			world.log << "away mission loaded: [map]"

		map_transition_config.Add(AWAY_MISSION_LIST)

		for(var/obj/effect/landmark/L in landmarks_list)
			if (L.name != "awaystart")
				continue
			awaydestinations.Add(L)

		world << "<span class='boldannounce'>Away mission loaded.</span>"

		SortAreas() //To add recently loaded areas

/proc/generateMapList(filename)
	var/list/potentialMaps = list()
	var/list/Lines = file2list(filename)

	if(!Lines.len)
		return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))

		else
			name = lowertext(t)

		if (!name)
			continue

		potentialMaps.Add(t)

	return potentialMaps


/proc/seedRuins(list/z_levels = null, budget = 0, whitelist = /area/space, list/potentialRuins = space_ruins_templates)
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

/obj/effect/ruin_loader/proc/Load(list/potentialRuins = space_ruins_templates, datum/map_template/template = null)
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
