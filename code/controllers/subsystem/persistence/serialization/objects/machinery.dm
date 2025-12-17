/obj/machinery/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, panel_open)
	return .

//if(movable_atom in component_parts)
//	continue

/obj/machinery/PersistentInitialize()
	. = ..()
	update_appearance()
	return .

/obj/machinery/camera/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, network)
	. += NAMEOF(src, camera_construction_state)
	. += NAMEOF(src, camera_upgrade_bitflags)
	. += NAMEOF(src, camera_enabled)
	return .

/obj/machinery/camera/PersistentInitialize()
	. = ..()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_XRAY)
		upgradeXRay()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_EMP_PROOF)
		upgradeEmpProof()
	if(camera_upgrade_bitflags & CAMERA_UPGRADE_MOTION)
		upgradeMotion()
	return .

// in game built cameras spawn deconstructed
/obj/machinery/camera/autoname/deconstructed/substitute_with_typepath(map_string)
	if(camera_construction_state != CAMERA_STATE_FINISHED)
		return FALSE

	var/cache_key = "[type]-[dir]"
	var/replacement_type = /obj/machinery/camera/autoname/directional
	if(isnull(GLOB.map_export_typepath_cache[cache_key]))
		var/directional = ""
		switch(dir)
			if(NORTH)
				directional = "/north"
			if(SOUTH)
				directional = "/south"
			if(EAST)
				directional = "/east"
			if(WEST)
				directional = "/west"

		var/full_path = "[replacement_type][directional]"
		var/typepath = text2path(full_path)

		if(ispath(typepath))
			GLOB.map_export_typepath_cache[cache_key] = typepath
		else
			GLOB.map_export_typepath_cache[cache_key] = FALSE
			stack_trace("Failed to convert [src] to typepath: [full_path]")

	var/cached_typepath = GLOB.map_export_typepath_cache[cache_key]
	if(cached_typepath)
		var/obj/machinery/camera/autoname/directional/typepath = cached_typepath
		var/list/variables = list()
		TGM_ADD_TYPEPATH_VAR(variables, typepath, network, network)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, camera_upgrade_bitflags, camera_upgrade_bitflags)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, camera_enabled, camera_enabled)
		TGM_ADD_TYPEPATH_VAR(variables, typepath, panel_open, panel_open)

		TGM_MAP_BLOCK(map_string, typepath, generate_tgm_typepath_metadata(variables))

	return cached_typepath

/obj/item/assembly/control/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, sync_doors)
	return .

/obj/machinery/button/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	// save the [/obj/item/assembly/control] inside the button that controls the id
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/machinery/button/PersistentInitialize()
	. = ..()
	var/obj/item/assembly/control/control_device = locate(/obj/item/assembly/control) in contents
	device = control_device
	setup_device()
	update_appearance()

/obj/machinery/conveyor_switch/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, conveyor_speed)
	. += NAMEOF(src, position)
	. += NAMEOF(src, oneway)
	return .

/obj/machinery/conveyor_switch/PersistentInitialize()
	. = ..()
	update_appearance()
	update_linked_conveyors()
	update_linked_switches()

/obj/machinery/conveyor/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, id)
	. += NAMEOF(src, speed)
	return .

/obj/machinery/photocopier/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, paper_stack)
	return .

/// CHECK IF ID_TAGS ARE NEEDED FOR FIREDOOR/FIREALARMS
/obj/machinery/door/firedoor/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, id_tag)
	return .

/obj/machinery/firealarm/get_save_vars(save_flags=ALL)
	. = ..()
	. -= NAMEOF(src, id_tag)
	return .

/obj/machinery/suit_storage_unit/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, density)
	. += NAMEOF(src, state_open)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, safeties)
	// ignore card reader stuff for now
	return .

/obj/machinery/suit_storage_unit/get_custom_save_vars(save_flags=ALL)
	. = ..()
	// since these aren't inside contents only save the typepaths
	if(suit)
		.[NAMEOF(src, suit_type)] = suit.type
	if(helmet)
		.[NAMEOF(src, helmet_type)] = helmet.type
	if(mask)
		.[NAMEOF(src, mask_type)] = mask.type
	if(mod)
		.[NAMEOF(src, mod_type)] = mod.type
	if(storage)
		.[NAMEOF(src, storage_type)] = storage.type
	return .

/obj/machinery/power/portagrav/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, on)
	. += NAMEOF(src, wire_mode)
	. += NAMEOF(src, grav_strength)
	. += NAMEOF(src, range)
	return .

/obj/machinery/power/portagrav/PersistentInitialize()
	. = ..()
	if(on)
		turn_on()
	return .

/obj/machinery/biogenerator/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, biomass)
	. += NAMEOF(src, welded_down)
	return .

/obj/machinery/biogenerator/PersistentInitialize()
	. = ..()
	update_appearance()
