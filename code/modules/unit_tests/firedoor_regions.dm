/**
 * Goes through every firedoor on the staiton z level and chunks them into "regions"
 *
 * Fire alarm regions are enclosed areas of firedoors
 * Closed airlocks break up regions as well
 *
 * Then, checks if every non-ignored region has a fire alarm in it
 */
/datum/unit_test/firedoor_regions
	priority = TEST_LONGER

/datum/unit_test/firedoor_regions/Run()
	var/list/detected_turfs = list()
	var/any_fail = FALSE
	var/datum/callback/room_cb = CALLBACK(src, PROC_REF(check_fire_area_callback))
	for(var/obj/machinery/door/firedoor/firedoor as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/firedoor))
		if(!is_station_level(firedoor.z))
			continue
		any_fail = check_fire_area(firedoor, room_cb, detected_turfs) || any_fail

	if(!any_fail)
		return
	TEST_FAIL("Some regions of enclosed fire doors did not have a fire alarm within! \
		Add a fire alarm, or mark the region as ignored with a firealarm_sanity landmark if intentional.")

/datum/unit_test/firedoor_regions/proc/check_fire_area(obj/machinery/door/firedoor/firedoor, datum/callback/room_cb, list/already_detected_turfs)
	. = FALSE
	for(var/turf/open/nearby as anything in get_adjacent_open_turfs(firedoor))
		if(nearby in already_detected_turfs)
			continue
		if(!istype(get_area(nearby), /area/station)) // uhhhh icebox spawns ruins on the station z level
			continue
		if(locate(/obj/machinery/door/firedoor) in nearby) // firedoors adjacent to another firedoors
			continue
		if(locate(/obj/effect/landmark/firealarm_sanity) in nearby)
			continue
		if(nearby.is_blocked_turf(exclude_mobs = TRUE)) // for windows, primarily.
			continue
		var/list/detected_area = detect_room(nearby, null, null, room_cb)
		if(!detected_area)
			continue

		already_detected_turfs |= detected_area
		if(!is_fire_alarm_in_list_of_turfs(detected_area))
			TEST_FAIL("No fire alarm in region: [AREACOORD(nearby)] (Region size: [length(detected_area)] turfs)")
			. = TRUE

	return .

/datum/unit_test/firedoor_regions/proc/is_fire_alarm_in_list_of_turfs(list/all_turfs)
	for(var/turf/open/turf_to_check as anything in all_turfs)
		if(locate(/obj/machinery/firealarm) in turf_to_check)
			return TRUE
	return FALSE

/datum/unit_test/firedoor_regions/proc/check_fire_area_callback(turf/checking)
	if(locate(/obj/effect/landmark/firealarm_sanity) in checking)
		return EXTRA_ROOM_CHECK_FAIL
	if(locate(/obj/machinery/door/firedoor) in checking)
		return EXTRA_ROOM_CHECK_SKIP
	return null
