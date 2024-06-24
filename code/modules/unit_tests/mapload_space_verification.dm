/// Verifies that there are no space turfs inside a station area, or on any planetary z-level. Sometimes, these are introduced during the load of the map and are not present in the DMM itself.
/// Let's just make sure that we have a stop-gap measure in place to catch these if they pop up so we don't put it onto production servers should something errant come up.
/datum/unit_test/mapload_space_verification
	// This test is quite taxing time-wise, so let's run it later than other faster tests.
	priority = TEST_LONGER

/datum/unit_test/mapload_space_verification/Run()
	// Is our current map a planetary station (NO space turfs allowed)? If so, check for ANY space turfs.
	if(SSmapping.is_planetary())
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
		/area/shuttle/abandoned,
		// Solars have lattices over space turfs, and are a valid placement for space turfs in a station area.
		/area/station/solars,
		//Birdshot Atmos has a special area, so we'll exclude that from lints here.
		/area/station/engineering/atmos/space_catwalk,
	))

	// We aren't planetary, so let's check area placements and ensure stuff lines up.
	for(var/turf/iterated_turf in ALL_TURFS())
		var/area/turf_area = get_area(iterated_turf)
		if(!isspaceturf(iterated_turf) || is_type_in_typecache(turf_area, excluded_area_typecache))
			continue // Alright, so let's assume we have intended behavior. If something yorks, we'll get a bare `/area` (maploader?) or a mapper is doing something they shouldn't be doing.
		// We need turf_area.type for the error message because we have fifteen million ruin areas named "Unexplored Location" and it's completely unhelpful here.
		TEST_FAIL("Space turf [iterated_turf.type] found in non-allowed area ([turf_area.type]) at [AREACOORD(iterated_turf)]! Please ensure that all space turfs are in an /area/space!")


/// Verifies that there are ZERO space turfs on a valid planetary station. We NEVER want space turfs here, so we do not check for /area/space here since something completely undesirable is happening.
/// There are also a few considerations specific to planetary stations included within, so let's spin it out into a separate proc for clarity.
/datum/unit_test/mapload_space_verification/proc/validate_planetary_map()
	// We want to get both the station level and the mining level (if the two are seperate for any reason).
	var/list/testable_levels = list()
	testable_levels += SSmapping.levels_by_trait(ZTRAIT_STATION) // Station z-levels get to be in by default because they can derail an entire round and cause LINDA to weep if a space turf is present.

	var/list/mining_levels = SSmapping.levels_by_trait(ZTRAIT_MINING)
	// Add in mining levels should they exist, and dupecheck to make sure we don't have any duplicates because it's valid to have a station and mining level be the same.
	for(var/mining_level in mining_levels)
		if(mining_level in testable_levels)
			continue
		testable_levels += mining_level

	for(var/level in testable_levels)
		var/testable_turfs = Z_TURFS(level)
		// Remember, any space turf is a failure.
		for(var/turf/open/space/iterated_turf in testable_turfs)
			// grab the type of the area that we're in too, because there's three different types of area types that have the name "Icemoon Wastes", for example
			var/area/invalid_area = get_area(iterated_turf)
			TEST_FAIL("Space turf found on planetary map! [AREACOORD(iterated_turf)] ([invalid_area.type]) Please verify the map file and remove any space turfs.")
