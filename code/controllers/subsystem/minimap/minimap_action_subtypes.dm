/*
/datum/action/minimap/xeno
	minimap_flags = MINIMAP_FLAG_XENO|MINIMAP_FLAG_EXCAVATION_ZONE

/datum/action/minimap/researcher
	minimap_flags = MINIMAP_FLAG_MARINE|MINIMAP_FLAG_EXCAVATION_ZONE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/marine
	minimap_flags = MINIMAP_FLAG_MARINE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/marine/external //Avoids keybind conflicts between inherent mob minimap and bonus minimap from consoles, CAS or similar.
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_TOGGLE_EXTERNAL_MINIMAP,
	)

/datum/action/minimap/marine/external/som
	minimap_flags = MINIMAP_FLAG_MARINE_SOM
	marker_flags = MINIMAP_FLAG_MARINE_SOM

/datum/action/minimap/ai	//I'll keep this as seperate type despite being identical so it's easier if people want to make different aspects different.
	minimap_flags = MINIMAP_FLAG_MARINE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/som
	minimap_flags = MINIMAP_FLAG_MARINE_SOM
	marker_flags = MINIMAP_FLAG_MARINE_SOM

/datum/action/minimap/observer
	minimap_flags = MINIMAP_FLAG_XENO|MINIMAP_FLAG_MARINE|MINIMAP_FLAG_MARINE_SOM|MINIMAP_FLAG_EXCAVATION_ZONE
	marker_flags = NONE
*/ // XANTODO: Minimap actions
// /datum/action/minimap

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
