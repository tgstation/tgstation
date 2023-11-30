#define EXPECTED_FLOOR_TYPE /turf/open/floor/iron
// Do this instead of just ChangeTurf to guarantee that baseturfs is completely default on-init behavior
#define RESET_TO_EXPECTED(turf) \
	turf.ChangeTurf(EXPECTED_FLOOR_TYPE);\
	turf.assemble_baseturfs(initial(turf.baseturfs))

/// Validates that unmodified baseturfs tear down properly
/datum/unit_test/baseturfs_unmodified_scrape

/datum/unit_test/baseturfs_unmodified_scrape/Run()
	// What this is specifically doesn't matter, just as long as the test is built for it
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "run_loc_floor_bottom_left should be an iron floor")

	RESET_TO_EXPECTED(run_loc_floor_bottom_left)
	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/floor/plating, "Iron floors should scrape away to plating")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/space, "Plating should scrape away to space")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/open/space, "Space should scrape away to space")

/datum/unit_test/baseturfs_unmodified_scrape/Destroy()
	RESET_TO_EXPECTED(run_loc_floor_bottom_left)
	return ..()

/// Validates that specially placed baseturfs tear down properly
/datum/unit_test/baseturfs_placed_on_top

/datum/unit_test/baseturfs_placed_on_top/Run()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "run_loc_floor_bottom_left should be an iron floor")

	// Do this instead of just ChangeTurf to guarantee that baseturfs is completely default on-init behavior
	RESET_TO_EXPECTED(run_loc_floor_bottom_left)

	run_loc_floor_bottom_left.place_on_top(/turf/closed/wall/rock)
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, /turf/closed/wall/rock, "Rock wall should've been placed on top")

	run_loc_floor_bottom_left.ScrapeAway()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "Rock wall should've been scraped off, back into the expected type")

/datum/unit_test/baseturfs_placed_on_top/Destroy()
	RESET_TO_EXPECTED(run_loc_floor_bottom_left)
	return ..()

/// Validates that specially placed baseturfs BELOW tear down properly
/datum/unit_test/baseturfs_placed_on_bottom

/datum/unit_test/baseturfs_placed_on_bottom/Run()
	TEST_ASSERT_EQUAL(run_loc_floor_bottom_left.type, EXPECTED_FLOOR_TYPE, "run_loc_floor_bottom_left should be an iron floor")

	// Do this instead of just ChangeTurf to guarantee that baseturfs is completely default on-init behavior
	RESET_TO_EXPECTED(run_loc_floor_bottom_left)

	run_loc_floor_bottom_left.place_on_bottom(/turf/closed/wall/rock)
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
	RESET_TO_EXPECTED(run_loc_floor_bottom_left)
	return ..()

#undef RESET_TO_EXPECTED
#undef EXPECTED_FLOOR_TYPE
