/// Conveys all log_mapping messages as unit test failures, as they all indicate mapping problems.
/datum/unit_test/log_mapping
	// Happen before all other tests, to make sure we only capture normal mapping logs.
	priority = TEST_PRE

/datum/unit_test/log_mapping/Run()
	var/static/regex/test_areacoord_regex = regex(@"\(-?\d+,-?\d+,(-?\d+)\)")

	for(var/log_entry in GLOB.unit_test_mapping_logs)
		// Only fail if AREACOORD was conveyed, and it's a station or mining z-level.
		// This is due to mapping errors don't have coords being impossible to diagnose as a unit test,
		// and various ruins frequently intentionally doing non-standard things.
		if(!test_areacoord_regex.Find(log_entry))
			continue
		var/z = text2num(test_areacoord_regex.group[1])
		if(!is_station_level(z) && !is_mining_level(z))
			continue

		TEST_FAIL(log_entry)

/// Verifies that there are no space turfs inside a station area, or on any planetary z-level. Sometimes, these are introduced during the load of the map and are not present in the DMM itself.
/// Let's just make sure that we have a stop-gap measure in place to catch these if they pop up so we don't put it onto production servers should something errant come up.
/datum/unit_test/mapload_space_verification
	// This test is quite taxing time-wise, so let's run it later than other faster tests.
	priority = TEST_ANTI_SPACE_TURF

/datum/unit_test/mapload_space_verification/Run()
	// Grab information on our current station.
	var/datum/map_config/current_map = SSmapping.config
	var/current_space_ruin_levels = current_map.space_ruin_levels
	var/current_empty_space_levels = current_map.space_empty_levels

	// Is our current map a planetary station (NO space turfs allowed)? If so, check for ANY space turfs.
	if(!(current_empty_space_levels && current_space_ruin_levels))
		validate_planetary_map()
		return

	// Let's explicitly outline valid areas to catch anything that we're... okay with for now, because there are some valid use cases (though we should try to avoid them).
	var/list/excluded_area_typecache = typecacheof(list(
		// Space! This is likely an intentional space turf, so let's not worry about it.
		/area/space,
		// Transit areas have space turfs in a valid placement.
		/area/shuttle/transit,
		// Space Ruins do their own thing (dilapidated lattices over space turfs, for instance). Rather than fuss over it, let's just let it through.
		/area/ruin/space,
		// Same stipulation as space ruins, but they're (ruined) shuttles instead.
		/area/shuttle/ruin,
		// Solars have lattices over space turfs, and are a valid placement for space turfs in a station area.
		/area/station/solars,
	))

	// We aren't planetary, so let's check area placements and ensure stuff lines up.
	for(var/turf/iterated_turf in world)
		var/area/turf_area = get_area(iterated_turf)
		if(!isspaceturf(iterated_turf) || is_type_in_typecache(turf_area, excluded_area_typecache))
			continue // Alright, so let's assume we have intended behavior. If something yorks, we'll get a bare `/area` (maploader?) or a mapper is doing something they shouldn't be doing.
		// We need turf_area.type for the error message because we have fifteen million ruin areas named "Unexplored Location" and it's completely unhelpful here.
		TEST_FAIL("Space turf found in non-allowed area ([turf_area.type]) at [AREACOORD(iterated_turf)]! Please ensure that all space turfs are in an /area/space!")


/// Verifies that there are ZERO space turfs on a valid planetary station. We NEVER want space turfs here, so we do not check for /area/space here since something completely undesirable is happening.
/// There are also a few considerations specific to planetary stations included within, so let's spin it out into a separate proc for clarity.
/datum/unit_test/mapload_space_verification/proc/validate_planetary_map()
	// We want to get both the station level and the mining level (if the two are seperate for any reason).
	var/list/testable_levels = list()
	var/list/mining_levels = SSmapping.levels_by_trait(ZTRAIT_MINING)
	testable_levels += SSmapping.levels_by_trait(ZTRAIT_STATION) // Station z-levels get to be in by default because they can derail an entire round and cause LINDA to weep if a space turf is present.

	for(var/station_level in testable_levels)
		for(var/mining_level in mining_levels)
			if(mining_level in testable_levels) // check for duplicates because we can have a Z-Level be both station and mining, don't add it if we already have it.
				continue
			testable_levels += mining_level

	for(var/level in testable_levels)
		var/testable_turfs = Z_TURFS(level)
		for(var/turf/iterated_turf in testable_turfs)
			if(isspaceturf(iterated_turf))
				TEST_FAIL("Space turf found on planetary map! [AREACOORD(iterated_turf)] Please verify the map file and remove any space turfs.")
