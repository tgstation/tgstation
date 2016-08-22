/datum/round_event_control/grid_check
	name = "Grid Check"
	typepath = /datum/round_event/grid_check
	weight = 10
	max_occurrences = 3

/datum/round_event/grid_check
	announceWhen	= 1
	startWhen = 1

/datum/round_event/grid_check/announce()
	priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", 'sound/AI/poweroff.ogg')


/datum/round_event/grid_check/start()

	var/static/list/smes_skip = typecacheof(list(/area/engine/engine_smes, /area/turret_protected))

	for(var/V in smes_list)
		var/obj/machinery/power/smes/S = V

		var/area/A = get_area(S)
		if(is_type_in_typecache(A,smes_skip) || S.z != ZLEVEL_STATION)
			continue

		S.energy_fail(rand(15,30))

	var/static/list/skipped_areas = typecacheof(list(/area/engine/engineering, /area/turret_protected/ai))

	for(var/P in apcs_list)
		var/obj/machinery/power/apc/C = P
		if(C.cell && C.z == ZLEVEL_STATION)
			var/area/A = get_area(C)

			if(is_type_in_typecache(A,skipped_areas))
				continue

			C.energy_fail(rand(30,120))