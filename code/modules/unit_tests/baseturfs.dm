#define EXPECTED_FLOOR_TYPE /turf/open/floor/iron

/// Validates that unmodified baseturfs tear down properly
/datum/unit_test/baseturfs_unmodified_scrape

/datum/unit_test/baseturfs_unmodified_scrape/Run()
	// What this is specifically doesn't matter, just as long as the test is built for it
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "run_loc_floor_bottom_left should be an iron floor")

	// Do this instead of ChangeTurf to guarantee that baseturfs is completely default on-init behavior
	new EXPECTED_FLOOR_TYPE(run_loc_floor_bottom_left)

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/floor/plating, "Iron floors should scrape away to plating")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/space, "Plating should scrape away to space")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/space, "Space should scrape away to space")

/datum/unit_test/baseturfs_unmodified_scrape/Destroy()
	new EXPECTED_FLOOR_TYPE(run_loc_floor_bottom_left)
	return ..()

/// Validates that specially placed baseturfs tear down properly
/datum/unit_test/baseturfs_placed_on_top

/datum/unit_test/baseturfs_placed_on_top/Run()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "run_loc_floor_bottom_left should be an iron floor")

	// Do this instead of ChangeTurf to guarantee that baseturfs is completely default on-init behavior
	new EXPECTED_FLOOR_TYPE(run_loc_floor_bottom_left)

	run_loc_floor_bottom_left.PlaceOnTop(/turf/closed/wall/rock)
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/closed/wall/rock, "Rock wall should've been placed on top")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "Rock wall should've been scraped off, back into the expected type")

/// Validates that specially placed baseturfs BELOW tear down properly
/datum/unit_test/baseturfs_placed_on_bottom

/datum/unit_test/baseturfs_placed_on_bottom/Run()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "run_loc_floor_bottom_left should be an iron floor")

	// Do this instead of ChangeTurf to guarantee that baseturfs is completely default on-init behavior
	new EXPECTED_FLOOR_TYPE(run_loc_floor_bottom_left)

	run_loc_floor_bottom_left.PlaceOnBottom(fake_turf_type = /turf/closed/wall/rock)
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "PlaceOnBottom shouldn't have changed turf")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/floor/plating, "Iron floors should scrape away to plating")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/space, "Plating should've scraped off to space")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/closed/wall/rock, "Space should've scraped down to a rock wall")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/floor/plating, "Rock wall should've scraped down back to plating (because it's a wall)")

/datum/unit_test/baseturfs_placed_on_bottom/Destroy()
	new EXPECTED_FLOOR_TYPE(run_loc_floor_bottom_left)
	return ..()

#undef EXPECTED_FLOOR_TYPE
