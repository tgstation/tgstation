var/list/potentialRandomZlevels = list()

proc/createRandomZlevel()

	var/text = file2text("maps/RandomZLevels/fileList.txt")

	if (!text) // No random Z-levels for you.
		return

	world << "\red \b Searching for away missions..."

	var/list/CL = dd_text2list(text, "\n")

	for (var/t in CL)
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
			name = lowertext(copytext(t, 1, pos))
		//	value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		potentialRandomZlevels.Add(t)


	if(potentialRandomZlevels.len)
		world << "\red \b Loading away mission..."

		var/map = pick(potentialRandomZlevels)
		var/file = file(map)
		if(isfile(file))
			maploader.load_map(file)

		for(var/obj/effect/landmark/L in world)
			if (L.name != "awaystart")
				continue
			awaydestinations.Add(L)

		world << "\red \b Away mission loaded."

	else
		world << "\red \b No away missions found."
		return