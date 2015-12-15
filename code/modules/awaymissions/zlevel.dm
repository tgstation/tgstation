#define RANDOM_UPPER_X 220
#define RANDOM_UPPER_Y 220

#define RANDOM_LOWER_X 30
#define RANDOM_LOWER_Y 30


var/global/list/potentialSpaceRuins = generateMapList(filename = "config/spaceRuinConfig.txt")

var/global/list/potentialLavaRuins = generateMapList(filename = "config/lavaRuinConfig.txt")

var/global/list/potentialUndergroundRuins = generateMapList(filename = "config/undergroundRuinConfig.txt")

/proc/createRandomZlevel()
	if(awaydestinations.len)	//crude, but it saves another var!
		return

	var/list/potentialRandomZlevels = generateMapList(filename = "config/awaymissionconfig.txt")

	if(potentialRandomZlevels.len)
		world << "<span class='boldannounce'>Loading away mission...</span>"

		var/map = pick(potentialRandomZlevels)
		var/file = file(map)
		if(isfile(file))
			maploader.load_map(file)
			world.log << "away mission loaded: [map]"

		map_transition_config.Add(AWAY_MISSION_LIST)

		for(var/obj/effect/landmark/L in landmarks_list)
			if (L.name != "awaystart")
				continue
			awaydestinations.Add(L)

		world << "<span class='boldannounce'>Away mission loaded.</span>"

	else
		world << "<span class='boldannounce'>No away missions found.</span>"
		return


/proc/generateMapList(filename)
	var/list/potentialMaps = list()
	var/list/Lines = file2list(filename)
	if(!Lines.len)	return
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






/proc/seedRuins(z_level = 1, ruin_number = 0, whitelist = /area/space, list/potentialRuins = potentialSpaceRuins)
	//var/list/turfs = get_area_turfs(whitelist, z_level)

	//if(!turfs.len)
	//	return

	while(ruin_number)
		var/sanity = 0
		var/valid = 0
		while(!valid)
			sanity++
			if(sanity > 100)
				break
			var/T = locate(rand(RANDOM_LOWER_X, RANDOM_UPPER_X), rand(RANDOM_LOWER_Y, RANDOM_UPPER_Y), z_level)

			for(var/turf/check in range(T, 20))
				var/area/new_area = get_area(check)
				if(new_area != whitelist)
					valid = 0
					break

			if(valid)
				var/obj/effect/ruin_loader/R = new /obj/effect/ruin_loader(T)
				R.Load(potentialRuins, -20, -20)
				ruin_number --

	return


/obj/effect/ruin_loader
	name = "random ruin"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	invisibility = 0

/obj/effect/ruin_loader/proc/Load(list/potentialRuins = potentialSpaceRuins, x_offset = 0, y_offset = 0)
	if(potentialRuins.len)
		world << "<span class='boldannounce'>Loading ruins...</span>"

		var/map = pick(potentialRuins)
		var/file = file(map)
		if(isfile(file))
			maploader.load_map(file, src.x - x_offset, src.y - y_offset, src.z)
			world.log << "ruins loaded: [map]"

		potentialRuins -= map //Don't want to load the same one twice
		world << "<span class='boldannounce'>Ruins loaded.</span>"

	else
		world << "<span class='boldannounce'>No ruins found.</span>"
		return

	qdel(src)



#undef RANDOM_UPPER_X
#undef RANDOM_UPPER_Y

#undef RANDOM_LOWER_X
#undef RANDOM_LOWER_Y