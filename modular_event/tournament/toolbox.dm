/obj/effect/landmark/toolbox
	name = "toolbox spawner"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "toolbox"
	layer = HIGH_OBJ_LAYER

	var/arena_id = ARENA_DEFAULT_ID
	var/team_id = ARENA_RED_TEAM

	var/obj/machinery/computer/tournament_controller/tournament_controller

/obj/effect/landmark/toolbox/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/toolbox/LateInitialize()
	. = ..()

	tournament_controller = GLOB.tournament_controllers[arena_id]
	if (isnull(tournament_controller))
		stack_trace("Toolbox spawn had an invalid arena_id: \"[arena_id]\"")
		qdel(src)
		return

	tournament_controller.toolbox_spawns[team_id] += list(src)

/obj/effect/landmark/toolbox/Destroy()
	if (!isnull(tournament_controller))
		tournament_controller.toolbox_spawns[team_id] -= src

	return ..()
