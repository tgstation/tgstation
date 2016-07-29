<<<<<<< HEAD
/datum/round_event_control/grey_tide
	name = "Grey Tide"
	typepath = /datum/round_event/grey_tide
	max_occurrences = 2
	min_players = 5

/datum/round_event/grey_tide
	announceWhen = 50
	endWhen = 20
	var/list/area/areasToOpen = list()
	var/list/potential_areas = list(/area/atmos,
									/area/bridge,
									/area/engine,
									/area/medical,
									/area/security,
									/area/quartermaster,
									/area/toxins)
	var/severity = 1


/datum/round_event/grey_tide/setup()
	announceWhen = rand(50, 60)
	endWhen = rand(20, 30)
	severity = rand(1,3)
	for(var/i in 1 to severity)
		var/picked_area = pick_n_take(potential_areas)
		for(var/area/A in world)
			if(istype(A, picked_area))
				areasToOpen += A


/datum/round_event/grey_tide/announce()
	if(areasToOpen && areasToOpen.len > 0)
		priority_announce("Gr3y.T1d3 virus detected in [station_name()] door subroutines. Severity level of [severity]. Recommend station AI involvement.", "Security Alert")
	else
		world.log << "ERROR: Could not initate grey-tide. No areas in the list!"
		kill()


/datum/round_event/grey_tide/start()
	for(var/area/A in areasToOpen)
		for(var/obj/machinery/light/L in A)
			L.flicker(10)

/datum/round_event/grey_tide/end()
	for(var/area/A in areasToOpen)
		for(var/obj/O in A)
			if(istype(O,/obj/machinery/power/apc))
				var/obj/machinery/power/apc/temp = O
				temp.overload_lighting()
			else if(istype(O,/obj/structure/closet/secure_closet))
				var/obj/structure/closet/secure_closet/temp = O
				temp.locked = 0
				temp.update_icon()
			else if(istype(O,/obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/temp = O
				temp.prison_open()
			else if(istype(O,/obj/machinery/door_timer))
				var/obj/machinery/door_timer/temp = O
				temp.timer_end(forced = TRUE)
=======
/datum/event/prison_break
	announceWhen	= 30
	oneShot			= 1

	var/releaseWhen = 25
	var/list/area/prisonAreas = list()


/datum/event/prison_break/setup()
	announceWhen = rand(50, 60)
	releaseWhen = rand(20, 30)
	src.startWhen = src.releaseWhen-1
	src.endWhen = src.releaseWhen+1

/datum/event/prison_break/announce()
	if(prisonAreas && prisonAreas.len > 0)
		command_alert("[pick("Gr3y.T1d3 virus","Malignant trojan")] detected in [station_name()] imprisonment subroutines. Recommend station AI involvement.", "Security Alert")
	else
		world.log << "ERROR: Could not initate grey-tide. Unable find prison or brig area."
		kill()


/datum/event/prison_break/start()
	for(var/area/A in areas)
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
