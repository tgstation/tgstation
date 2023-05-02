///ensures that get_turf_pixel() returns turfs within the bounds of the map,
///even when called on a movable with its sprite out of bounds
/datum/unit_test/get_turf_pixel

/datum/unit_test/get_turf_pixel/Run()
	//we need long larry to peek over the top edge of the earth
	var/turf/north = locate(1, world.maxy, run_loc_floor_bottom_left.z)

	//hes really long, so hes really good at peaking over the edge of the map
	var/mob/living/simple_animal/hostile/megafauna/colossus/long_larry = allocate(/mob/living/simple_animal/hostile/megafauna/colossus, north)
	TEST_ASSERT(istype(get_turf_pixel(long_larry), /turf), "get_turf_pixel() isnt clamping a mob whos sprite is above the bounds of the world inside of the map.")
