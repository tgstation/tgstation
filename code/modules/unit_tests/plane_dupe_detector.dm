///Checks if some idiot didnt give two planes the same layer
/datum/unit_test/plane_dupe_detector

/datum/unit_test/plane_dupe_detector/Run()
	var/list/plane_integer_list = list()
	for(var/atom/movable/screen/plane_master/air as anything in subtypesof(/atom/movable/screen/plane_master))
		if(!initial(air.plane))
			continue
		if(plane_integer_list.Find("[initial(air.plane)]"))
			var/atom/movable/screen/plane_master/first = plane_integer_list["[initial(air.plane)]"]
			TEST_FAIL("PLANE CONFLICT DETECTED!! The [initial(air.name)] and [initial(first.name)] both use plane [initial(air.plane)].")
		plane_integer_list["[initial(air.plane)]"] = air
