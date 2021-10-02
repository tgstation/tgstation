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

	for (var/obj/effect/landmark/tournament_spawn_valid_location/landmark in range(3, src))
		landmark.invisibility = INVISIBILITY_ABSTRACT
		spawn_locations += get_turf(landmark)

	if (spawn_locations.len == 0)
		stack_trace("Arena spawn had no nearby thunderdome spawns (for [arena_id] on team [team])")
		qdel(src)
		return

	tournament_controller.valid_team_spawns[team] = spawn_locations

/obj/effect/landmark/tournament_spawn_valid_location
	name = "valid tournament spawn location"
	icon_state = "tdome_admin"

	// Makes it so it actually shows up in range
	invisibility = INVISIBILITY_MAXIMUM
