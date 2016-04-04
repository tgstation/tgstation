/datum/round_event_control/prison_break
	name = "Prison Break"
	typepath = /datum/round_event/prison_break
	max_occurrences = 2
	min_players = 5

/datum/round_event/prison_break
	announceWhen = 50
	endWhen = 20
	var/list/area/prisonAreas = list()


/datum/round_event/prison_break/setup()
	announceWhen = rand(50, 60)
	endWhen = rand(20, 30)

	for(var/area/security/A in world)
		if(istype(A, /area/security/prison) || istype(A, /area/security/brig))
			prisonAreas += A


/datum/round_event/prison_break/announce()
	if(prisonAreas && prisonAreas.len > 0)
		priority_announce("Gr3y.T1d3 virus detected in [station_name()] imprisonment subroutines. Recommend station AI involvement.", "Security Alert")
	else
		world.log << "ERROR: Could not initate grey-tide. Unable find prison or brig area."
		kill()


/datum/round_event/prison_break/start()
	for(var/area/A in prisonAreas)
		for(var/obj/machinery/light/L in A)
			L.flicker(10)

/datum/round_event/prison_break/end()
	for(var/area/A in prisonAreas)
		for(var/obj/O in A)
			if(istype(O,/obj/machinery/power/apc))
				var/obj/machinery/power/apc/temp = O
				temp.overload_lighting()
			else if(istype(O,/obj/structure/closet/secure_closet/brig))
				var/obj/structure/closet/secure_closet/brig/temp = O
				temp.locked = 0
				temp.update_icon()
			else if(istype(O,/obj/machinery/door/airlock/security))
				var/obj/machinery/door/airlock/security/temp = O
				temp.prison_open()
			else if(istype(O,/obj/machinery/door/airlock/glass_security))
				var/obj/machinery/door/airlock/glass_security/temp = O
				temp.prison_open()
			else if(istype(O,/obj/machinery/door_timer))
				var/obj/machinery/door_timer/temp = O
				temp.timer_end(forced = TRUE)