/// Verifies that an area's perception of their "turfs" is correct, and no other area overlaps with them
/// Quite slow, but needed
/datum/unit_test/area_contents
	priority = TEST_LONGER

/datum/unit_test/area_contents/Run()
	// First, we check that there are no entries in more then one area
	// That or duplicate entries
	for (var/area/area_to_test in GLOB.areas)
		area_to_test.cannonize_contained_turfs()
		for (var/i in 1 to area_to_test.turfs_by_zlevel.len)
			if (!islist(area_to_test.turfs_by_zlevel[i]))
				TEST_FAIL("zlevel index [i] in [area_to_test.type] is not a list.")

			for (var/turf/turf_to_check as anything in area_to_test.turfs_by_zlevel[i])
				if (!isturf(turf_to_check))
					TEST_FAIL("Found a [turf_to_check.type] in [area_to_test.type]'s turf listing")

				if (turf_to_check.in_contents_of)
					var/area/existing = turf_to_check.in_contents_of
					if (existing == turf_to_check.loc)
						TEST_FAIL("Found a duplicate turf [turf_to_check.type] inside [area_to_test.type]'s turf listing")
					else
						TEST_FAIL("Found a shared turf [turf_to_check.type] between [area_to_test.type] and [existing.type]'s turf listings")

				var/area/turfs_actual_area = turf_to_check.loc
				if (turfs_actual_area != area_to_test)
					TEST_FAIL("Found a turf [turf_to_check.type] which is IN [turfs_actual_area.type], but is registered as being in [area_to_test.type]")

				turf_to_check.in_contents_of = turfs_actual_area

	for(var/turf/position in ALL_TURFS())
		if(!position.in_contents_of)
			TEST_FAIL("Found a turf [position.type] inside [position.loc.type] that is NOT stored in any area's turf listing")
