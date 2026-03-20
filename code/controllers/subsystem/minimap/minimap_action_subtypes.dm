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


/datum/action/minimap/nuclear/New(Target, new_minimap_flags, new_marker_flags, tactical_map)
	. = ..()
	for(var/obj/item/disk/nuclear/nuke_disk as anything in SSpoints_of_interest.real_nuclear_disks)
		my_map.add_marker(nuke_disk, MINIMAP_FLAG_ALL, image('icons/ui_icons/minimap/map_blips_large.dmi', null, "green_disk_off", MINIMAP_BLIPS_LAYER))
	for(var/obj/machinery/nuclearbomb/nuke as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb))
		my_map.add_marker(nuke, MINIMAP_FLAG_ALL, image('icons/ui_icons/minimap/map_blips_large.dmi', null, "nuke_off", MINIMAP_BLIPS_LAYER))
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DEVICE_ARMED, PROC_REF(on_nuke_armed))
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DEVICE_DISARMED, PROC_REF(on_nuke_disarmed))

/datum/action/minimap/nuclear/proc/on_nuke_armed(datum/source, obj/machinery/nuclearbomb/bomb)
	SIGNAL_HANDLER
	var/image/blip = my_map.images_by_source[bomb]
	if(blip)
		blip.icon_state = "nuke_on"

/datum/action/minimap/nuclear/proc/on_nuke_disarmed(datum/source, obj/machinery/nuclearbomb/bomb)
	SIGNAL_HANDLER
	var/image/blip = my_map.images_by_source[bomb]
	if(blip)
		blip.icon_state = "nuke_off"
