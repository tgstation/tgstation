// How much "space" we give the edge of the map
GLOBAL_LIST_INIT(potentialRandomZlevels, generateMapList(filename = "[global.config.directory]/awaymissionconfig.txt"))

/proc/createRandomZlevel()
	if(GLOB.potentialRandomZlevels && GLOB.potentialRandomZlevels.len)
		to_chat(world, "<span class='boldannounce'>Loading away mission...</span>")
		var/map = pick(GLOB.potentialRandomZlevels)
		load_new_z_level(map, "Away Mission")
		to_chat(world, "<span class='boldannounce'>Away mission loaded.</span>")

/obj/effect/landmark/awaystart
	name = "away mission spawn"
	desc = "Randomly picked away mission spawn points."
	var/id
	var/delay = TRUE // If the generated destination should be delayed by configured gateway delay

/obj/effect/landmark/awaystart/Initialize()
	. = ..()
	var/datum/gateway_destination/point/current
	for(var/datum/gateway_destination/point/D in GLOB.gateway_destinations)
		if(D.id == id)
			current = D
	if(!current)
		current = new
		current.id = id
		if(delay)
			current.wait = CONFIG_GET(number/gateway_delay)
		GLOB.gateway_destinations += current
	current.target_turfs += get_turf(src)

/obj/effect/landmark/awaystart/nodelay
	delay = FALSE

/proc/generateMapList(filename)
	. = list()
	var/list/Lines = world.file2list(filename)

	if(!Lines.len)
		return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (t[1] == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))

		else
			name = lowertext(t)

		if (!name)
			continue

		. += t
