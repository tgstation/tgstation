/datum/controller/subsystem/shuttle/proc/create_ship(datum/map_template/shuttle/voidcrew/ship_template_to_spawn)
	// load a ship map

	UNTIL(!shuttle_loading)
	ship_template_to_spawn = new
	shuttle_loading = TRUE
	if (!load_template(ship_template_to_spawn))
		stack_trace("Failed to load ship!")
		shuttle_loading = FALSE
		return
	shuttle_loading = FALSE

	var/obj/structure/overmap/ship/ship_to_spawn = new(SSovermap.get_unused_overmap_square(tries = INFINITY))
	ship_to_spawn.shuttle = preview_shuttle // preview shuttle is set in `load_template()`
	return preview_shuttle
