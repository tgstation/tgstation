/datum/zLevel/away
	name = "awaymission"
	movementJammed = 1 //no drifting here

/proc/createRandomZlevel(override = 0)
	if(awaydestinations.len && !override)	//crude, but it saves another var!
		return

	var/list/potentialRandomZlevels = list()
	to_chat(world, "<span class='danger'>Searching for away missions...</span>")
	var/list/Lines = file2list("maps/RandomZLevels/fileList.txt")
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
	//	var/value = null

		if (pos)
            // No, don't do lowertext here, that breaks paths on linux
			name = copytext(t, 1, pos)
		//	value = copytext(t, pos + 1)
		else
            // No, don't do lowertext here, that breaks paths on linux
			name = t

		if (!name)
			continue

		if(!isfile(name))
			warning("fileList.txt contains a map that does not exist: [name]")
			continue

		potentialRandomZlevels.Add(name)


	while(1)
		if(potentialRandomZlevels.len)
			to_chat(world, "<span class='danger'>Loading away mission...</span>")
			var/map = pick(potentialRandomZlevels)
			log_game("Loading away mission [map]")

			var/file = file(map)
			if(isfile(file))
				maploader.load_map(file)

				for(var/obj/effect/landmark/L in landmarks_list)
					if (L.name != "awaystart")
						continue
					awaydestinations.Add(L)

				to_chat(world, "<span class='danger'>Away mission loaded.</span>")
				return
			to_chat(world, "<span class='danger'>Failed to load away mission. Trying again...</span>")
			// Remove map from list
			potentialRandomZlevels -= map
		else
			to_chat(world, "<span class='danger'>No away missions found.</span>")
			return