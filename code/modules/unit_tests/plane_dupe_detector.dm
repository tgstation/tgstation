///Checks if we don't have two planes on the same layer
/datum/unit_test/plane_dupe_detector

/datum/unit_test/plane_dupe_detector/Run()
	var/list/plane_integer_list = list()
	for(var/atom/movable/screen/plane_master/plane_path as anything in subtypesof(/atom/movable/screen/plane_master))
		if(!initial(plane_path.plane))
			continue
		if(plane_integer_list.Find("[initial(plane_path.plane)]"))
			var/atom/movable/screen/plane_master/duplicate_plane_path = plane_integer_list["[initial(plane_path.plane)]"]
			TEST_FAIL("PLANE CONFLICT DETECTED!! The [initial(plane_path.name)] and [initial(duplicate_plane_path.name)] both use plane [initial(plane_path.plane)].")
		plane_integer_list["[initial(plane_path.plane)]"] = plane_path
