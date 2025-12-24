/obj/machinery/door/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, density)
	. -= NAMEOF(src, opacity)
	return .

/obj/machinery/door/airlock/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, autoname)
	. += NAMEOF(src, emergency)

	if(!autoname)
		. += NAMEOF(src, name)

	. -= NAMEOF(src, density)
	. -= NAMEOF(src, opacity)
	return .

/obj/machinery/door/airlock/on_object_saved(map_string, turf/current_loc)
	if(abandoned)
		TGM_MAP_BLOCK(map_string, /obj/effect/mapping_helpers/airlock/abandoned, null)
	else // Only save these if not abandoned
		if(welded)
			TGM_MAP_BLOCK(map_string, /obj/effect/mapping_helpers/airlock/welded, null)
		if(locked && !cycle_pump) // cycle pumps has funky bolt behavior that needs to be ignored
			TGM_MAP_BLOCK(map_string, /obj/effect/mapping_helpers/airlock/locked, null)
	if(cyclelinkeddir)
		var/obj/effect/mapping_helpers/airlock/cyclelink_helper/typepath = /obj/effect/mapping_helpers/airlock/cyclelink_helper
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, cyclelinkeddir)
		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	if(closeOtherId)
		var/obj/effect/mapping_helpers/airlock/cyclelink_helper_multi/typepath = /obj/effect/mapping_helpers/airlock/cyclelink_helper_multi
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, cycle_id, closeOtherId)
		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	if(unres_sides)
		for(var/heading in list(NORTH, SOUTH, EAST, WEST))
			if(unres_sides & heading)
				var/obj/effect/mapping_helpers/airlock/unres/typepath = /obj/effect/mapping_helpers/airlock/unres
				var/list/variables = list()
				TGM_ADD_TYPEPATH_VAR(variables, typepath, dir, heading)
				TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

/obj/machinery/door/poddoor/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	return .
