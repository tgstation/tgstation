var/datum/subsystem/mapping/SSmapping

/datum/subsystem/mapping
	name = "Mapping"
	init_order = 100000
	flags = SS_NO_FIRE
	display_order = 50

	var/list/nuke_tiles = list()
	var/list/nuke_threats = list()


/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSmapping)
	return ..()


/datum/subsystem/mapping/Initialize(timeofday)
	preloadTemplates()
	// Pick a random away mission.
	createRandomZlevel()
	// Generate mining.

	var/mining_type = MINETYPE
	if (mining_type == "lavaland")
		seedRuins(list(5), config.lavaland_budget, /area/lavaland/surface/outdoors, lava_ruins_templates)
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

	seedRuins(space_zlevels, config.space_budget, /area/space, space_ruins_templates)

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
		if(!istype(d) || qdeleted(d))
			nuke_threats -= d

	var/threats = nuke_threats.len

	for(var/N in nuke_tiles)
		var/turf/open/floor/T = N
		T.icon_state = (threats ? "rcircuitanim" : T.icon_regular_floor)

/datum/subsystem/mapping/Recover()
	flags |= SS_NO_INIT
