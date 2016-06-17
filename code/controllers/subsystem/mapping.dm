var/datum/subsystem/mapping/SSmapping

/datum/subsystem/mapping
	name = "Mapping"
	init_order = 100000
	flags = SS_NO_FIRE
	display_order = 50


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
		seedRuins(5, config.lavaland_budget, /area/lavaland/surface/outdoors, lava_ruins_templates)
		spawn_rivers()
	else
		make_mining_asteroid_secrets()

	// deep space ruins
	seedRuins(7, rand(0,2), /area/space, space_ruins_templates)
	seedRuins(8, rand(0,2), /area/space, space_ruins_templates)
	seedRuins(9, rand(0,2), /area/space, space_ruins_templates)

	// Set up Z-level transistions.
	setup_map_transitions()
	..()

/datum/subsystem/mapping/Recover()
	flags |= SS_NO_INIT