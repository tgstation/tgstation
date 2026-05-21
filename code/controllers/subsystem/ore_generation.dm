
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
	/// List of ore turfs that want to be randomized
	var/list/turf/closed/mineral/random/ore_turfs = list()
	/// Amount of ores by type generated
	var/list/ores_generated = list()
	/// Probabilities by type and depth to generate ores
	var/list/list/list/ore_spread_probabilities = list()

/datum/controller/subsystem/ore_generation/Initialize()
	/// First, lets sort each ore_vent here based on their distance to the landmark, then we'll assign sizes.
	var/list/sort_vents = list()
	for(var/obj/structure/ore_vent/vent as anything in possible_vents)

		var/obj/landmark_anchor //We need to find the mining epicenter to gather distance from.
		for(var/obj/possible_landmark as anything in GLOB.mining_center) // have to check multiple due to icebox
			if(possible_landmark.z == vent.z)
				landmark_anchor = possible_landmark
				break

		if(!landmark_anchor) //We're missing a mining epicenter landmark, but it's not crash-worthy.
			vent.vent_size_setup(random = TRUE, force_size = null, map_loading = TRUE)
			continue

		sort_vents.Insert(length(sort_vents), vent)
		sort_vents[vent] = get_dist(get_turf(vent),get_turf(landmark_anchor))

	sortTim(sort_vents, GLOBAL_PROC_REF(cmp_numeric_asc), associative = TRUE) // Should sort list from closest to farthest.
	possible_vents = sort_vents // Now we can work with the main list

	var/cutoff = round((length(possible_vents) / 3))
	var/vent_size_level = SMALL_VENT_TYPE

	for(var/obj/structure/ore_vent/vent as anything in possible_vents)
		vent.vent_size_setup(random = FALSE, force_size = vent_size_level, map_loading = TRUE)
		cutoff--
		if(cutoff > 0 || vent_size_level == LARGE_VENT_TYPE)
			continue
		cutoff = round((length(possible_vents) / 3))
		switch(vent_size_level)
			if(SMALL_VENT_TYPE)
				vent_size_level = MEDIUM_VENT_TYPE
			if(MEDIUM_VENT_TYPE)
				vent_size_level = LARGE_VENT_TYPE

	//Finally, we're going to round robin through the list of ore vents and assign a mineral to them until complete.
	//Basically, we're going to round robin through the list of ore vents and assign a mineral to them until complete.
	for(var/obj/structure/ore_vent/vent as anything in possible_vents)
		if(vent.unique_vent)
			continue //Ya'll already got your minerals.
		vent.generate_mineral_breakdown(map_loading = TRUE)

	logger.Log(
		LOG_CATEGORY_CAVE_GENERATION,
		"Ore Generation spawned the following vent sizes",
		list(
			"large" = LAZYACCESS(GLOB.ore_vent_sizes, LARGE_VENT_TYPE),
			"medium" = LAZYACCESS(GLOB.ore_vent_sizes, MEDIUM_VENT_TYPE),
			"small" = LAZYACCESS(GLOB.ore_vent_sizes, SMALL_VENT_TYPE),
		),
	)

	calculate_rock_edges()
	for (var/turf/closed/mineral/random/rock in ore_turfs) // Typecheck in case they got destroyed
		rock.randomize_ore()

	calculate_ore_spread()

	return SS_INIT_SUCCESS

/// Generates debug data about ore spread among rock turfs
/datum/controller/subsystem/ore_generation/proc/calculate_ore_spread()
	var/list/result = list()
	var/list/totals = list("chance" = 0, "raw_sum" = 0)
	var/summary_count = 0
	for (var/turf/closed/mineral/random/rock_type as anything in ore_spread_probabilities)
		var/list/rock_data = ore_spread_probabilities[rock_type]
		var/list/result_rock = list()
		var/total_count = 0
		var/total_chance = 0
		for (var/spread_range in rock_data)
			var/list/dist_info = rock_data[spread_range]
			for (var/ore_type in dist_info - list("chance", "count"))
				if (!result_rock[ore_type])
					result_rock[ore_type] = 0
				result_rock[ore_type] += dist_info[ore_type] * dist_info["chance"] / initial(rock_type.mineral_chance) * dist_info["count"]
			total_count += dist_info["count"]
			total_chance += dist_info["chance"] * dist_info["count"]

		result_rock["chance"] = total_chance / total_count
		result_rock["count"] = total_count
		totals["chance"] += total_chance
		summary_count += total_count
		result[rock_type] = result_rock

	for (var/turf/closed/mineral/random/rock_type as anything in result)
		var/list/rock_data = result[rock_type]
		var/raw_sum = 0
		for (var/ore_type in rock_data)
			if (!ispath(ore_type))
				continue
			rock_data[ore_type] /= summary_count
			raw_sum += rock_data[ore_type]
			if (!totals[ore_type])
				totals[ore_type] = 0
			if (ispath(ore_type, /turf/closed/mineral/gibtonite/volcanic))
				totals[/turf/closed/mineral/gibtonite/volcanic] += rock_data[ore_type]
			else
				totals[ore_type] += rock_data[ore_type]
		rock_data["raw_sum"] = raw_sum
		totals["raw_sum"] += raw_sum

	for (var/spawn_type in totals)
		if (!ispath(spawn_type))
			continue
		totals[spawn_type] /= totals["raw_sum"] / 104

	totals["count"] = summary_count
	if (summary_count > 0)
		totals["chance"] /= summary_count
	result["total"] = totals
	ore_spread_probabilities = result

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
