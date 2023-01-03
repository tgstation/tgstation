/// Verifies that an area's perception of their "turfs" is correct, and no other area overlaps with them
/// Quite slow, but needed
/datum/unit_test/area_contents
	priority = TEST_LONGER

/datum/unit_test/area_contents/Run()
	// First, we check that there are no entries in more then one area
	// That or duplicate entries
	for(var/area/space in GLOB.areas)
		for(var/turf/position as anything in space.get_contained_turfs())
			if(!isturf(position))
				TEST_FAIL("Found a [position.type] in [space.type]'s turf listing")

			if(position.in_contents_of)
				var/area/existing = position.in_contents_of
				if(existing == space)
					TEST_FAIL("Found a duplicate turf [position.type] inside [space.type]'s turf listing")
				else
					TEST_FAIL("Found a shared turf [position.type] between [space.type] and [existing.type]'s turf listings")

			var/area/dream_spot = position.loc
			if(dream_spot != space)
				TEST_FAIL("Found a turf [position.type] which is IN [dream_spot.type], but is registered as being in [space.type]")

			position.in_contents_of = space

	for(var/turf/position in ALL_TURFS())
		if(!position.in_contents_of)
			TEST_FAIL("Found a turf [position.type] inside [position.loc.type] that is NOT stored in any area's turf listing")
