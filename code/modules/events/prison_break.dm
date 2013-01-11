/datum/event/prison_break
	announceWhen	= 50
	endWhen			= 50
	oneShot			= 1

	var/releaseWhen = 25
	var/list/area/prisonAreas = list()


/datum/event/prison_break/announce()
	if(prisonAreas && prisonAreas.len > 0)
		command_alert("Gr3y.T1d3 virus detected in [station_name()] imprisonment subroutines. Recommend station AI involvement.", "Security Alert")
	else
		world.log << "ERROR: Could not initate grey-tide. Unable find prison or brig area."
		kill()


/datum/event/prison_break/start()
	for(var/area/A in world)
		if(istype(A, /area/security/prison) || istype(A, /area/security/brig))
			prisonAreas += A

	if(prisonAreas && prisonAreas.len > 0)
		for(var/area/A in prisonAreas)
			for(var/obj/machinery/light/L in A)
				L.flicker(10)


/datum/event/prison_break/tick()
	if(activeFor == releaseWhen)
		if(prisonAreas && prisonAreas.len > 0)
			for(var/area/A in prisonAreas)
				for(var/obj/machinery/power/apc/temp_apc in A)
					temp_apc.overload_lighting()

				for(var/obj/structure/closet/secure_closet/brig/temp_closet in A)
					temp_closet.locked = 0
					temp_closet.icon_state = temp_closet.icon_closed

				for(var/obj/machinery/door/airlock/security/temp_airlock in A)
					temp_airlock.prison_open()

				for(var/obj/machinery/door/airlock/glass_security/temp_glassairlock in A)
					temp_glassairlock.prison_open()

				for(var/obj/machinery/door_timer/temp_timer in A)
					temp_timer.releasetime = 1