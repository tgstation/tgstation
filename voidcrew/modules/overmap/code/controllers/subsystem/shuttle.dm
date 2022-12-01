/datum/controller/subsystem/shuttle/proc/create_ship(datum/map_template/shuttle/voidcrew/ship_template_to_spawn)
	RETURN_TYPE(/obj/structure/overmap/ship)

	UNTIL(!shuttle_loading)
	var/obj/structure/overmap/ship/ship_to_spawn = new(SSovermap.get_unused_overmap_square(tries = INFINITY))
	ship_template_to_spawn = new ship_template_to_spawn

	shuttle_loading = TRUE
	SSair.can_fire = FALSE // fuck you
	var/obj/docking_port/mobile/voidcrew/loaded = action_load(ship_template_to_spawn)
	SSair.can_fire = TRUE
	shuttle_loading = FALSE

	if(!loaded)
		qdel(ship_to_spawn)
		return

	loaded.current_ship = ship_to_spawn
	ship_to_spawn.name = loaded.name
	ship_to_spawn.assign_source_template(ship_template_to_spawn)
	ship_to_spawn.shuttle = loaded

	// assign landmarks as needed
	var/turf/safe_turf = get_safe_random_station_turf(loaded.shuttle_areas)
	new /obj/effect/landmark/blobstart(safe_turf) // StationLoving component
	new /obj/effect/landmark/observer_start(safe_turf) // Observer and UnitTests

	return ship_to_spawn

/client/add_admin_verbs()
	. = ..()
	add_verb(src, list(
		PROC_REF(respawn_ship),
		PROC_REF(spawn_specific_ship),
	))

/client/remove_admin_verbs()
	. = ..()
	remove_verb(src, list(
		PROC_REF(respawn_ship),
		PROC_REF(spawn_specific_ship),
	))

#define RESPAWN_FORCE "Force Respawn"
/client/proc/respawn_ship()
	set name = "Respawn Initial Ship"
	set category = "Overmap"
	if(SSovermap.initial_ship)
		var/resp = tgui_alert(usr, "Initial ship already exists. This can delete players and their progress", "Shits Fucked", list(RESPAWN_FORCE, "Cancel"))
		if(resp != RESPAWN_FORCE)
			return
		qdel(SSovermap.initial_ship)
	SSovermap.spawn_initial_ship()
#undef RESPAWN_FORCE

/client/proc/spawn_specific_ship()
	set name = "Spawn Specific Ship"
	set category = "Overmap"
	var/static/list/choices
	if(!choices)
		choices = list()
		for(var/ship in subtypesof(/datum/map_template/shuttle/voidcrew))
			var/datum/map_template/shuttle/voidcrew/V = ship
			choices[initial(V.name)] = V
	var/ship_to_spawn = tgui_input_list(usr, "Which ship do you want to spawn?", "Spawn Specific Ship", choices)
	if(!ship_to_spawn)
		return

	var/obj/structure/overmap/ship/spawned = SSshuttle.create_ship(choices[ship_to_spawn])
	mob.client?.admin_follow(spawned.shuttle)
