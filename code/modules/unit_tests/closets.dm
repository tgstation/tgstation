/*
 * Unit test for checking that closets don't have more items in them
 * when created, than they would be able to hold naturally.
 * If a closet when created would have too many items, opening and closing
 * it would leave some items on the floor.
 */
/datum/unit_test/closet_contents
	// At time of writing, there are 185 unique closets. A 256 big
	// area will be sufficient for now.
	reservation_width = 18 // 2 is consumed by the border wall
	reservation_height = 18
	border_test_turf_type = /turf/closed/wall/r_wall
	gravity = TRUE

/datum/unit_test/closet_contents/Run()
	var/list/test_turfs = block(run_loc_bottom_left, run_loc_top_right)

	for(var/_closettype in typesof(/obj/structure/closet))
		// Spawn each closet on its own turf, so they don't interfere.
		var/turf/closet_turf = popleft(test_turfs)
		while(istype(closet_turf, /turf/closed))
			closet_turf = popleft(test_turfs)

		if(!closet_turf)
			Fail("Ran out of unused turfs to spawn closets on.")

		var/obj/structure/closet/closet = allocate(_closettype, closet_turf)

		var/start_count = length(closet.contents)

		closet.open(null, force = TRUE)

		// Believe it or not, some closets CEASE TO EXIST when opened.
		if(QDELETED(closet))
			continue

		closet.close()

		TEST_ASSERT(!closet.opened, "Closet ([closet], [closet.type]) failed to close.")

		var/end_count = length(closet.contents)
		TEST_ASSERT_EQUAL(start_count, end_count, "Closet ([closet], [closet.type]) does not have same number of items as it started with, after being opened and closed. Started: [start_count], Ended: [end_count]")
