/datum/round_event_control/grid_check
	name = "Grid Check"
	typepath = /datum/round_event/grid_check
	weight = 10
	min_players = 3
	earliest_start = 6000
	max_occurrences = 3

/datum/round_event/grid_check
	announceWhen	= 1
	startWhen = 1

/datum/round_event/grid_check/announce()
	priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", 'sound/AI/poweroff.ogg')


/datum/round_event/grid_check/start()
	for(var/obj/machinery/power/smes/S in machines)
		if(istype(get_area(S), /area/turret_protected) || S.z != ZLEVEL_STATION)
			continue

		S.energy_fail(rand(15,30))

	var/list/skipped_areas = list(/area/engine/engineering, /area/turret_protected/ai)

	for(var/obj/machinery/power/apc/C in apcs_list)
		if(C.cell && C.z == ZLEVEL_STATION)
			var/area/A = get_area(C)

			var/skip = 0
			for(var/area_type in skipped_areas)
				if(istype(A,area_type))
					skip = 1
					break
			if(skip) continue

			C.energy_fail(rand(30,60))