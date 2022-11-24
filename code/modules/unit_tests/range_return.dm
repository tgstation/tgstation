/// This tests for an unspecified bit of behavior we rely on in energy_ball.dm code
/// Essentially, as of the current byond version, range and view will return turfs in what looks "roughly" like a circle
/// So we can be guarenteed that if we find a turf, it will be the closest turf of that sort, or at least one of them
/// This code tests for that. If this ever fails, remove the logic fron energy_ball.dm, and test if spiral_turfs would be faster
/datum/unit_test/range_return

/datum/unit_test/range_return/Run()
	var/x = (run_loc_floor_top_right.x - run_loc_floor_bottom_left.x) / 2
	var/y = (run_loc_floor_top_right.y - run_loc_floor_bottom_left.y) / 2
	// We take the turf equidistant from the two corners
	var/turf/center = locate(x + run_loc_floor_bottom_left.x, y + run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	// Now, we'll iterate over all the turfs in range, and insure we don't see one with a higher dist then a previously seen instance
	var/least_distance = 0
	for(var/turf/lad in orange(center, min(x, y)))
		// get_dist is essentially max(dist deltas)
		// So this is valid even if the corners aren't visited first
		var/dist = get_dist(center, lad)
		TEST_ASSERT(dist >= least_distance, "Range returned a turf of greater distance BEFORE a turf of lower distance. \
			Behavior has changed, remove all code that relies on this behavior")
		least_distance = dist
