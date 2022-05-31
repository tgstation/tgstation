///ensures that get_turf_pixel() returns turfs within the bounds of the map, even when called on a movable with its sprite out of bounds
/datum/unit_test/get_turf_pixel/Run()
	//we need long larry to peek over the top edge of the earth
	var/turf/north = locate(1, world.maxy, run_loc_floor_bottom_left.z)
	var/turf/east = locate(world.maxx, world.maxy, run_loc_floor_bottom_left.z)
	var/turf/south = locate(world.maxx, 1, run_loc_floor_bottom_left.z)
	var/turf/west = locate(1, 1, run_loc_floor_bottom_left.z)

	///long larry is long indeed
	var/long_larry_coefficient = 30
	var/matrix/identity_matrix = matrix()

	var/matrix/north_transform = identity_matrix.Scale(1,long_larry_coefficient)
	var/matrix/east_transform = identity_matrix.Scale(long_larry_coefficient, 1)
	var/matrix/south_transform = identity_matrix.Scale(1, -long_larry_coefficient)
	var/matrix/west_transform = identity_matrix.Scale(-long_larry_coefficient, 1)

	///hes really long, so hes really good at peaking over the edge of the map
	var/mob/living/simple_animal/hostile/megafauna/colossus/long_larry = allocate(/mob/living/simple_animal/hostile/megafauna/colossus, north)
	long_larry.transform = north_transform
	TEST_ASSERT(get_turf_pixel(long_larry) != null, "get_turf_pixel() isnt clamping a mob whos sprite is above the bounds of the world inside of the map.")

	long_larry.loc = east
	long_larry.transform = east_transform
	TEST_ASSERT(get_turf_pixel(long_larry) != null, "get_turf_pixel() isnt clamping a mob whos sprite extends east of the bounds of the world inside of the map.")

	long_larry.loc = south
	long_larry.transform = south_transform
	TEST_ASSERT(get_turf_pixel(long_larry) != null, "get_turf_pixel() isnt clamping a mob whos sprite extends south of the bounds of the world inside of the map.")

	long_larry.loc = west
	long_larry.transform = west_transform
	TEST_ASSERT(get_turf_pixel(long_larry) != null, "get_turf_pixel() isnt clamping a mob whos sprite extends west of the bounds of the world inside of the map.")




