/// Verifies that an area's perception of their "turfs" is correct, and no other area overlaps with them
/// Quite slow, but needed
/datum/unit_test/area_contents

/datum/unit_test/area_contents/Run()
	/// assoc list of turfs -> areas
	var/list/turf_to_area = list()
	// First, we check that there are no entries in more then one area
	// That or duplicate entries
	for(var/area/lad in world)
		for(var/turf/thing as anything in lad.contained_turfs)
			if(!isturf(thing))
				TEST_FAIL("Found a [thing.type] in [lad.type]'s turf listing")
			var/area/existing = turf_to_area[thing]
			if(existing == lad)
				TEST_FAIL("Found a duplicate turf inside [lad.type]'s turf listing")
			else if(existing)
				TEST_FAIL("Found a duplicate turf inside [lad.type] AND [existing.type]'s turf listing")

			var/area/dream = thing.loc
			if(dream != lad)
				TEST_FAIL("Found a turf [thing.type] which is IN [dream.type], but is registered as being in [lad.type]")

			turf_to_area[thing] = lad

	for(var/turf/position in ALL_TURFS())
		if(!turf_to_area[position])
			TEST_FAIL("Found a turf [position.type] inside [position.loc.type] that is NOT stored in any area's turf listing")

