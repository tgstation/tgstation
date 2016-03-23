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
	else
		world << "<span class='boldannounce'>No away missions found.</span>"
		return


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


/proc/seedRuins(z_level = 1, ruin_number = 0, whitelist = /area/space, list/potentialRuins = space_ruins_templates)
	ruin_number = min(ruin_number, potentialRuins.len)

	while(ruin_number)
		var/sanity = 0
		var/valid = FALSE
		var/datum/map_template/template = potentialRuins[pick(potentialRuins)]
		while(!valid)
			valid = TRUE
			sanity++
			if(sanity > 100)
				ruin_number--
				break
			var/turf/T = locate(rand(25, world.maxx - 25), rand(25, world.maxy - 25), z_level)

			for(var/turf/check in template.get_affected_turfs(T,1))
				var/area/new_area = get_area(check)
				if(!(istype(new_area, whitelist)))
					valid = FALSE
					break

			if(valid)
				world.log << "Ruins marker placed at [T.x][T.y][T.z]"
				var/obj/effect/ruin_loader/R = new /obj/effect/ruin_loader(T)
				R.Load(potentialRuins,template)
				ruin_number --

	return

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
	world << "<span class='boldannounce'>Loading ruins...</span>"
	if(!template && possible_ruins.len)
		template = safepick(possible_ruins)
	if(!template)
		world << "<span class='boldannounce'>No ruins found.</span>"
		return
	template.load(get_turf(src),centered = TRUE)
	template.loaded++
	world << "<span class='boldannounce'>Ruins loaded.</span>"
	qdel(src)
