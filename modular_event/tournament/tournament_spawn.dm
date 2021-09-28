/obj/machinery/tournament_spawn
	name = "tournament spawn"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	resistance_flags = INDESTRUCTIBLE

	/// In case we have multiple arena controllers at once.
	var/arena_id = ARENA_DEFAULT_ID
	/// Team ID
	var/team = "default"

/obj/machinery/tournament_spawn/red
	name = "Red Team Spawnpoint"
	color = "red"
	team = ARENA_RED_TEAM

/obj/machinery/tournament_spawn/green
	name = "Green Team Spawnpoint"
	color = "green"
	team = ARENA_GREEN_TEAM

/obj/machinery/tournament_spawn/LateInitialize()
	. = ..()

	var/obj/machinery/computer/tournament_controller/tournament_controller = GLOB.tournament_controllers[arena_id]
	if (isnull(tournament_controller))
		stack_trace("Arena spawn had an invalid arena_id: \"[arena_id]\"")
		qdel(src)
		return

	var/list/spawn_locations = list()

	var/area/area = get_area(src)
	for (var/obj/effect/landmark/thunderdome/thunderdome_landmark in area)
		spawn_locations += get_turf(thunderdome_landmark)

	tournament_controller.valid_team_spawns[team] = spawn_locations

/obj/effect/landmark/thunderdome/one/Initialize()
	..()
	return INITIALIZE_HINT_NORMAL

/obj/effect/landmark/thunderdome/two/Initialize()
	..()
	return INITIALIZE_HINT_NORMAL
