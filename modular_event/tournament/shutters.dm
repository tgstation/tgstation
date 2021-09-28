/obj/machinery/door/poddoor/LateInitialize()
	. = ..()

	var/obj/machinery/computer/tournament_controller/tournament_controller = GLOB.tournament_controllers[id]
	if (!istype(tournament_controller))
		return

	tournament_controller.arena_shutters += src

/obj/machinery/door/poddoor/Destroy()
	var/obj/machinery/computer/tournament_controller/tournament_controller = GLOB.tournament_controllers[id]
	if (istype(tournament_controller))
		tournament_controller.arena_shutters -= src

	return ..()
