/proc/power_failure()
	priority_announce("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", 'sound/ai/poweroff.ogg')
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(istype(get_area(S), /area/ai_monitored/turret_protected) || !(S.z in GLOB.station_z_levels))
			continue
		S.charge = 0
		S.output_level = 0
		S.output_attempt = 0
		S.update_icon()
		S.power_change()

	var/list/skipped_areas = list(/area/engine/engineering, /area/engine/supermatter, /area/engine/atmospherics_engine, /area/ai_monitored/turret_protected/ai)

	for(var/area/A in world)
		if( !A.requires_power || A.always_unpowered )
			continue

		var/skip = 0
		for(var/area_type in skipped_areas)
			if(istype(A,area_type))
				skip = 1
				break
		if(A.contents)
			for(var/atom/AT in A.contents)
				if(!(AT.z in GLOB.station_z_levels)) //Only check one, it's enough.
					skip = 1
				break
		if(skip) continue
		A.power_light = FALSE
		A.power_equip = FALSE
		A.power_environ = FALSE
		A.power_change()

	for(var/obj/machinery/power/apc/C in GLOB.apcs_list)
		if(C.cell && (C.z in GLOB.station_z_levels))
			var/area/A = C.area

			var/skip = 0
			for(var/area_type in skipped_areas)
				if(istype(A,area_type))
					skip = 1
					break
			if(skip) continue

			C.cell.charge = 0

/proc/power_restore()

	priority_announce("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", 'sound/ai/poweron.ogg')
	for(var/obj/machinery/power/apc/C in GLOB.machines)
		if(C.cell && (C.z in GLOB.station_z_levels))
			C.cell.charge = C.cell.maxcharge
			C.failure_timer = 0
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(!(S.z in GLOB.station_z_levels))
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.update_icon()
		S.power_change()
	for(var/area/A in world)
		if(!istype(A, /area/space) && !istype(A, /area/shuttle) && !istype(A, /area/arrival))
			A.power_light = TRUE
			A.power_equip = TRUE
			A.power_environ = TRUE
			A.power_change()

/proc/power_restore_quick()

	priority_announce("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", 'sound/ai/poweron.ogg')
	for(var/obj/machinery/power/smes/S in GLOB.machines)
		if(!(S.z in GLOB.station_z_levels))
			continue
		S.charge = S.capacity
		S.output_level = S.output_level_max
		S.output_attempt = 1
		S.update_icon()
		S.power_change()

