// How much "space" we give the edge of the map
GLOBAL_LIST_INIT(potentialRandomZlevels, generateMapList(filename = "awaymissionconfig.txt"))
GLOBAL_LIST_INIT(potentialConfigRandomZlevels, generate_map_list_from_directory(directory = "[global.config.directory]/away_missions/"))

/proc/createRandomZlevel(config_gateway = FALSE)
	var/map
	if(config_gateway && GLOB.potentialConfigRandomZlevels?.len)
		map = pick_n_take(GLOB.potentialConfigRandomZlevels)
	else if(GLOB.potentialRandomZlevels?.len)
		map = pick_n_take(GLOB.potentialRandomZlevels)
	else
		return to_chat(world, span_boldannounce("No valid away mission files, loading aborted."))
	to_chat(world, span_boldannounce("Loading away mission..."))
	var/loaded = load_new_z_level(map, "Away Mission", config_gateway)
	to_chat(world, span_boldannounce("Away mission [loaded ? "loaded" : "aborted due to errors"]."))
	if(!loaded)
		message_admins("Away mission [map] loading failed due to errors.")
		log_admin("Away mission [map] loading failed due to errors.")
		createRandomZlevel(config_gateway)

/obj/effect/landmark/awaystart
	name = "away mission spawn"
	desc = "Randomly picked away mission spawn points."
	var/id
	var/delay = TRUE // If the generated destination should be delayed by configured gateway delay

/obj/effect/landmark/awaystart/Initialize(mapload)
	. = ..()
	var/datum/gateway_destination/point/current
	for(var/datum/gateway_destination/point/D in GLOB.gateway_destinations)
		if(D.id == id)
			current = D
	if(!current)
		current = new
		current.name = name
		current.id = id
		if(delay)
			var/list/waits_by_id = CONFIG_GET(keyed_list/gateway_delays_by_id)
			var/wait_to_use = !isnull(waits_by_id[id]) ? waits_by_id[id] : CONFIG_GET(number/gateway_delay)
			current.wait = wait_to_use
		GLOB.gateway_destinations += current
	current.target_turfs += get_turf(src)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/awaystart/nodelay
	delay = FALSE

/obj/effect/landmark/awaystart/beach
	name = "beach away spawn"
	id = AWAYSTART_BEACH

/obj/effect/landmark/awaystart/museum
	name = "buseum away spawn"
	id = AWAYSTART_MUSEUM

/obj/effect/landmark/awaystart/research
	name = "research outpost away spawn"
	id = AWAYSTART_RESEARCH

/obj/effect/landmark/awaystart/caves
	name = "caves away spawn"
	id = AWAYSTART_CAVES

/obj/effect/landmark/awaystart/moonoutpost
	name = "Moon Outpost 19 away spawn"
	id = AWAYSTART_MOONOUTPOST

/obj/effect/landmark/awaystart/snowcabin
	name = "snow cabin away spawn"
	id = AWAYSTART_SNOWCABIN

/obj/effect/landmark/awaystart/snowdin
	name = "Snowdin away spawn"
	id = AWAYSTART_SNOWDIN

/obj/effect/landmark/awaystart/underground
	name = "Underground Outpost 45 away spawn"
	id = AWAYSTART_UNDERGROUND

/proc/generateMapList(filename)
	. = list()
	filename = "[global.config.directory]/[SANITIZE_FILENAME(filename)]"
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
			name = LOWER_TEXT(copytext(t, 1, pos))

		else
			name = LOWER_TEXT(t)

		if (!name)
			continue

		. += t

/// Returns a list of all maps to be found in the directory that is passed in.
/proc/generate_map_list_from_directory(directory)
	var/list/config_maps = list()
	var/list/maps = flist(directory)
	for(var/map_file in maps)
		if(!findtext(map_file, ".dmm"))
			continue
		config_maps += (directory + map_file)
	return config_maps
