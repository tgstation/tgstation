var/datum/subsystem/mapping/SSmapping

/datum/subsystem/mapping
	name = "Mapping"
	init_order = 13
	flags = SS_NO_FIRE
	display_order = 50

	var/list/nuke_tiles = list()
	var/list/nuke_threats = list()

	var/datum/map_config/previous_map_config
	var/datum/map_config/config
	var/datum/map_config/next_map_config

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSmapping)
	if(!previous_map_config)
		previous_map_config = new("previous_map.json")
		if(previous_map_config.defaulted)
			previous_map_config = null
	if(!config)
		config = new
	return ..()


/datum/subsystem/mapping/Initialize(timeofday)
	if(config.defaulted)
		world << "<span class='boldannounce'>Unable to load next map config, defaulting to Box Station</span>"
	loadWorld()
	preloadTemplates()
	// Pick a random away mission.
	createRandomZlevel()
	// Generate mining.

	var/mining_type = config.minetype
	if (mining_type == "lavaland")
		seedRuins(list(5), global.config.lavaland_budget, /area/lavaland/surface/outdoors, lava_ruins_templates)
		spawn_rivers()
	else
		make_mining_asteroid_secrets()

	// deep space ruins
	var/space_zlevels = list()
	for(var/i in ZLEVEL_SPACEMIN to ZLEVEL_SPACEMAX)
		switch(i)
			if(ZLEVEL_MINING, ZLEVEL_LAVALAND, ZLEVEL_EMPTY_SPACE)
				continue
			else
				space_zlevels += i

	seedRuins(space_zlevels, global.config.space_budget, /area/space, space_ruins_templates)

	// Set up Z-level transistions.
	setup_map_transitions()
	..()

/* Nuke threats, for making the blue tiles on the station go RED
   Used by the AI doomsday and the self destruct nuke.
*/

/datum/subsystem/mapping/proc/add_nuke_threat(datum/nuke)
	nuke_threats[nuke] = TRUE
	check_nuke_threats()

/datum/subsystem/mapping/proc/remove_nuke_threat(datum/nuke)
	nuke_threats -= nuke
	check_nuke_threats()

/datum/subsystem/mapping/proc/check_nuke_threats()
	for(var/datum/d in nuke_threats)
		if(!istype(d) || QDELETED(d))
			nuke_threats -= d

	var/threats = nuke_threats.len

	for(var/N in nuke_tiles)
		var/turf/open/floor/T = N
		T.icon_state = (threats ? "rcircuitanim" : T.icon_regular_floor)

/datum/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
	previous_map_config = SSmapping.previous_map_config
	config = SSmapping.config
	next_map_config = SSmapping.next_map_config

#define INIT_ANNOUNCE(X) world << "<span class='boldannounce'>[X]</span>"; log_world(X)
/datum/subsystem/mapping/proc/loadWorld()
	var/dmm_suite/loader = new
	//TODO: FUCKING ERROR CHECKING YOU SCRUB
	INIT_ANNOUNCE("Loading Map '[config.map_name]'...")
	loader.load_map(file(config.GetFullMapPath()), 0, 0, 1, no_afterchange = TRUE)
	INIT_ANNOUNCE("Loaded station!")
	loader.load_map(file("_maps/map_files/generic/z3.dmm"), no_afterchange = TRUE)
	loader.load_map(file("_maps/map_files/generic/z4.dmm"), no_afterchange = TRUE)
	INIT_ANNOUNCE("Loading [config.minetype]...")
	loader.load_map(file("_maps/map_files/generic/[config.minetype].dmm"), no_afterchange = TRUE)
	INIT_ANNOUNCE("Loaded mining level!")
	loader.load_map(file("_maps/map_files/generic/z6.dmm"), no_afterchange = TRUE)
	loader.load_map(file("_maps/map_files/generic/z7.dmm"), no_afterchange = TRUE)
	loader.load_map(file("_maps/map_files/generic/z8.dmm"), no_afterchange = TRUE)
	loader.load_map(file("_maps/map_files/generic/z9.dmm"), no_afterchange = TRUE)
	loader.load_map(file("_maps/map_files/generic/z10.dmm"), no_afterchange = TRUE)
	loader.load_map(file("_maps/map_files/generic/z11.dmm"), no_afterchange = TRUE)
	SortAreas()
	INIT_ANNOUNCE("Done loading map!") //can't think of anywhere better to put it
#undef INIT_ANNOUNCE

/datum/subsystem/mapping/proc/maprotate()
	var/players = clients.len
	var/list/mapvotes = list()
	//count votes
	for (var/client/c in clients)
		var/vote = c.prefs.preferred_map
		if (!vote)
			if (global.config.defaultmap)
				mapvotes[global.config.defaultmap.map_name] += 1
			continue
		mapvotes[vote] += 1

	//filter votes
	for (var/map in mapvotes)
		if (!map)
			mapvotes.Remove(map)
		if (!(map in global.config.maplist))
			mapvotes.Remove(map)
			continue
		var/datum/map_config/VM = global.config.maplist[map]
		if (!VM)
			mapvotes.Remove(map)
			continue
		if (VM.voteweight <= 0)
			mapvotes.Remove(map)
			continue
		if (VM.config_min_users > 0 && players < VM.config_min_users)
			mapvotes.Remove(map)
			continue
		if (VM.config_max_users > 0 && players > VM.config_max_users)
			mapvotes.Remove(map)
			continue

		mapvotes[map] = mapvotes[map]*VM.voteweight

	var/pickedmap = pickweight(mapvotes)
	if (!pickedmap)
		return
	var/datum/map_config/VM = global.config.maplist[pickedmap]
	message_admins("Randomly rotating map to [VM.map_name]")
	. = changemap(VM)
	if (.)
		world << "<span class='boldannounce'>Map rotation has chosen [VM.map_name] for next round!</span>"

/datum/subsystem/mapping/proc/changemap(var/datum/map_config/VM)	
	if(!VM.MakeNextMap())
		next_map_config = new(default_to_box = TRUE)
		message_admins("Failed to set new map with next_map.json for [VM.map_name]! Using default as backup!")
		return

	next_map_config = VM
	return TRUE

/datum/subsystem/mapping/Shutdown()
	if(config)
		config.MakePreviousMap()