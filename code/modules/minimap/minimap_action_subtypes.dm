/datum/action/minimap/observer/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!minimap_displayed)
		map_object.stop_polling[owner] = TRUE
		return
	var/list/clicked_coords = map_object.get_coords_from_click(owner)
	if(!clicked_coords)
		toggle_minimap(FALSE)
		return
	var/turf/clicked_turf = locate(clicked_coords[1], clicked_coords[2], owner.z)
	if(!clicked_turf)
		toggle_minimap(FALSE)
		return
	// Taken directly from observer/DblClickOn
	owner.abstract_move(clicked_turf)
	owner.update_parallax_contents()
	// Close minimap
	toggle_minimap(FALSE)

/datum/action/minimap/nuclear
	minimap_flags = MINIMAP_FLAG_NUCLEAR
	marker_flags = MINIMAP_FLAG_NUCLEAR

/datum/action/minimap/map_drawing/nuclear
	minimap_flags = MINIMAP_FLAG_NUCLEAR
	marker_flags = MINIMAP_FLAG_NUCLEAR
