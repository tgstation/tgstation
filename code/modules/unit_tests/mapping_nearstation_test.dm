///Detects movables that may have been accidentally placed in space, as well as movables which do not have the proper nearspace area (meaning they aren't lit properly.)
/datum/unit_test/mapping_nearstation_test
	priority = TEST_PRE

/datum/unit_test/mapping_nearstation_test/Run()
	if(SSmapping.is_planetary())
		return //No need to test for orphaned spaced atoms on this map.

	var/list/safe_atoms = typecacheof(list(
		/atom/movable/mirage_holder,
		/obj/docking_port,
		/obj/effect/landmark,
		/obj/effect/abstract,
		/obj/effect/mapping_error,
	)) //Mapping stuff that we don't actually have to be concerned about.
	var/list/safe_areas = typecacheof(list(
		/area/misc/testroom,
		/area/station/holodeck,
	))

	for(var/station_z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/list/turfs_to_check = Z_TURFS(station_z)
		for(var/turf/station_turf as anything in turfs_to_check)
			var/area/turf_area = station_turf.loc
			if(turf_area.static_lighting || is_type_in_typecache(turf_area, safe_areas)) //Only care about turfs that don't have lighting enabled.
				continue
			var/has_thing = FALSE
			for(var/atom/movable/thing_on_the_turf as anything in station_turf.contents) //Find an item on the turf, this can help the mapper identify the turf more easily when combined with the exact coords.
				if(is_type_in_typecache(thing_on_the_turf, safe_atoms))
					continue
				TEST_FAIL("[station_turf.x], [station_turf.y], [station_turf.z]: [thing_on_the_turf.type] with area of type [turf_area.type]")
				has_thing = TRUE
				break
			if(!has_thing && !isspaceturf(station_turf) && !istype(station_turf, /turf/open/openspace)) //In case it's just a turf without an area
				if(istype(station_turf, /turf/open/floor/engine/hull/ceiling))
					TEST_FAIL("[station_turf.x], [station_turf.y], [station_turf.z]: [station_turf.type] with area of type [turf_area.type]. The turf on the z-level below is a shuttle dock and generated me! An error landmark has been generated on the map for easier debugging!")
				else
					TEST_FAIL("[station_turf.x], [station_turf.y], [station_turf.z]: [station_turf.type] with area of type [turf_area.type]")
	if(!succeeded)
		TEST_FAIL("Movable Atom located without a proper area. Please verify they are supposed to be there. If they are correct, change the area to /area/space/nearstation (or the correct surrounding type).")
