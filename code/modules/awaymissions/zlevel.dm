// How much "space" we give the edge of the map
var/global/list/potentialRandomZlevels = generateMapList(filename = "config/awaymissionconfig.txt")

/proc/createRandomZlevel()
	if(awaydestinations.len)	//crude, but it saves another var!
		return

	if(potentialRandomZlevels && potentialRandomZlevels.len)
		world << "<span class='boldannounce'>Loading away mission...</span>"
		var/map = pick(potentialRandomZlevels)
		load_new_z_level(map)
		world << "<span class='boldannounce'>Away mission loaded.</span>"

/proc/reset_gateway_spawns(reset = FALSE)
	for(var/obj/machinery/gateway/G in world)
		if(reset)
			G.randomspawns = awaydestinations
		else
			G.randomspawns.Add(awaydestinations)

/obj/effect/landmark/awaystart
	name = "away mission spawn"
	desc = "Randomly picked away mission spawn points"

/obj/effect/landmark/awaystart/New()
	awaydestinations += src
	..()

/obj/effect/landmark/awaystart/Destroy()
	awaydestinations -= src
	..()

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