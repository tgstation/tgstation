
SUBSYSTEM_DEF(ore_generation)
	name = "Ore Generation"
	wait = 60 SECONDS
	dependencies = list(
		/datum/controller/subsystem/atoms,
	)
	runlevels = RUNLEVEL_GAME

	/// All ore vents that are currently producing boulders.
	var/list/obj/structure/ore_vent/processed_vents = list()
	/// All the ore vents that are currently in the game, not just the ones that are producing boulders.
	var/list/obj/structure/ore_vent/possible_vents = list()
	/// All the boulders that have been produced by ore vents to be pulled by BRM machines.
	var/list/obj/item/boulder/available_boulders = list()
	/**
	 * A list of all the minerals that are being mined by ore vents. We reset this list every time cave generation is done.
	 * Generally Should be empty by the time initialize ends on lavaland.
	 * Each key value is the number of vents that will have this ore as a unique possible choice.
	 * If we call cave_generation more than once, we copy a list from the lists in lists/ores_spawned.dm
	 */
	var/list/ore_vent_minerals = list()

	/// A tracker of how many of each ore vent size we have in the game. Useful for tracking purposes.

/datum/controller/subsystem/ore_generation/Initialize()
	//Basically, we're going to round robin through the list of ore vents and assign a mineral to them until complete.
	while(length(ore_vent_minerals) > 0) //Keep looping if there's more to assign
		var/stallbreaker = 0
		for(var/obj/structure/ore_vent/vent as anything in possible_vents)
			if(length(ore_vent_minerals) <= 0) //But break early if there's none left.
				break
			if(vent.unique_vent)
				continue //Ya'll already got your minerals.
			if(length(difflist(first = ore_vent_minerals, second = vent.mineral_breakdown, skiprep = 1)))
				vent.generate_mineral_breakdown(new_minerals = 1, map_loading = TRUE)
			else
				stallbreaker++
				if(stallbreaker >= length(possible_vents))
					break //We've done all we can here. break inner loop
				continue
		if(stallbreaker >= length(possible_vents))
			break //We've done all we can here. break outer loop

	/// Handles roundstart logging
	logger.Log(
		LOG_CATEGORY_CAVE_GENERATION,
		"Ore Generation spawned the following ores based on vent proximity",
		list(
			"[ORE_WALL_FAR]" = GLOB.post_ore_random["[ORE_WALL_FAR]"],
			"[ORE_WALL_LOW]" = GLOB.post_ore_random["[ORE_WALL_LOW]"],
			"[ORE_WALL_MEDIUM]" = GLOB.post_ore_random["[ORE_WALL_MEDIUM]"],
			"[ORE_WALL_HIGH]" = GLOB.post_ore_random["[ORE_WALL_HIGH]"],
			"[ORE_WALL_VERY_HIGH]" = GLOB.post_ore_random["[ORE_WALL_VERY_HIGH]"],
		),
	)
	logger.Log(
		LOG_CATEGORY_CAVE_GENERATION,
		"Ore Generation spawned the following ores randomly",
		list(
			"[ORE_WALL_FAR]" = GLOB.post_ore_manual["[ORE_WALL_FAR]"],
			"[ORE_WALL_LOW]" = GLOB.post_ore_manual["[ORE_WALL_LOW]"],
			"[ORE_WALL_MEDIUM]" = GLOB.post_ore_manual["[ORE_WALL_MEDIUM]"],
			"[ORE_WALL_HIGH]" = GLOB.post_ore_manual["[ORE_WALL_HIGH]"],
			"[ORE_WALL_VERY_HIGH]" = GLOB.post_ore_manual["[ORE_WALL_VERY_HIGH]"],
		),
	)
	logger.Log(
		LOG_CATEGORY_CAVE_GENERATION,
		"Ore Generation spawned the following vent sizes",
		list(
			"large" = LAZYACCESS(GLOB.ore_vent_sizes, LARGE_VENT_TYPE),
			"medium" = LAZYACCESS(GLOB.ore_vent_sizes, MEDIUM_VENT_TYPE),
			"small" = LAZYACCESS(GLOB.ore_vent_sizes, SMALL_VENT_TYPE),
		),
	)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ore_generation/fire(resumed)
	available_boulders.Cut() // reset upon new fire.
	for(var/obj/structure/ore_vent/current_vent as anything in processed_vents)

		var/local_vent_count = 0
		for(var/obj/item/boulder/old_rock in current_vent.loc)
			available_boulders += old_rock
			local_vent_count++

		if(local_vent_count >= MAX_BOULDERS_PER_VENT)
			continue //We don't want to be accountable for literally hundreds of unprocessed boulders for no reason.

		available_boulders += current_vent.produce_boulder()
