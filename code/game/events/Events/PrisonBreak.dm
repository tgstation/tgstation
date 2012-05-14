/datum/event/prisonbreak

	Announce()

		for (var/obj/machinery/power/apc/temp_apc in world)
			if(istype(get_area(temp_apc), /area/security/prison))
				temp_apc.overload_lighting()
			if(istype(get_area(temp_apc), /area/security/brig))
				temp_apc.overload_lighting()
	//	for (var/obj/machinery/computer/prison_shuttle/temp_shuttle in world)
	//		temp_shuttle.prison_break()
		for (var/obj/structure/closet/secure_closet/brig/temp_closet in world)
			if(istype(get_area(temp_closet), /area/security/prison))
				temp_closet.locked = 0
				temp_closet.icon_state = temp_closet.icon_closed
		for (var/obj/machinery/door/airlock/security/temp_airlock in world)
			if(istype(get_area(temp_airlock), /area/security/prison))
				temp_airlock.prison_open()
			if(istype(get_area(temp_airlock), /area/security/brig))
				temp_airlock.prison_open()
		for (var/obj/machinery/door/airlock/glass_security/temp_glassairlock in world)
			if(istype(get_area(temp_glassairlock), /area/security/prison))
				temp_glassairlock.prison_open()
			if(istype(get_area(temp_glassairlock), /area/security/brig))
				temp_glassairlock.prison_open()
		for (var/obj/machinery/door_timer/temp_timer in world)
			if(istype(get_area(temp_timer), /area/security/brig))
				temp_timer.releasetime = 1
		sleep(150)
		command_alert("Gr3y.T1d3 virus detected in [station_name()] imprisonment subroutines. Recommend station AI involvement.", "Security Alert")
