/obj/structure/cable/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, cable_color)
	. += NAMEOF(src, cable_layer)

	. -= NAMEOF(src, color)
	return .

/obj/item/stack/cable_coil/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, cable_color)

	// wires modify several vars immediately after init which results
	// in excessive save data that should be omitted
	. -= NAMEOF(src, pixel_x)
	. -= NAMEOF(src, pixel_y)
	. -= NAMEOF(src, color)
	return .

/obj/item/rwd/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, current_amount)
	. += NAMEOF(src, cable_layer)
	return .

/obj/item/rwd/PersistentInitialize()
	. = ..()
	update_appearance()

// these spawn underneath apc's but are created by them in initialization
/obj/machinery/power/terminal/is_saveable(turf/current_loc, list/obj_blacklist)
	if(locate(/obj/machinery/power/apc) in loc)
		return FALSE

	return ..()

/obj/machinery/power/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, cable_layer)
	return .

/obj/machinery/power/apc/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, opened)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, coverlocked)
	. += NAMEOF(src, lighting)
	. += NAMEOF(src, equipment)
	. += NAMEOF(src, environ)
	. += NAMEOF(src, cell_type)
	if(!auto_name)
		. += NAMEOF(src, name)

	// TODO save the wire data but need to include states for cute wires, signalers attached to wires, etc.
	//. += NAMEOF(src, shorted)
	return .

/obj/machinery/power/apc/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(cell_type)
		.[NAMEOF(src, start_charge)] = round((cell.charge / cell.maxcharge) * 100)
	return .

/obj/machinery/power/smes/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, input_level)
	. += NAMEOF(src, output_level)
	return .

/obj/machinery/power/smes/get_custom_save_vars(save_flags=ALL)
	. = ..()
	.[NAMEOF(src, charge)] = total_charge()
	return .

/obj/item/stock_parts/power_store/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, rigged)
	return .

/obj/machinery/power/port_gen/pacman/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, active)
	. += NAMEOF(src, sheets)
	. += NAMEOF(src, sheet_left)
	return .

/obj/machinery/power/port_gen/pacman/PersistentInitialize()
	. = ..()
	if(active)
		active = FALSE // gets reset to TRUE after TogglePower()
		TogglePower()
	return .

/obj/machinery/power/solar_control/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, track)
	return .

/obj/machinery/power/solar_control/get_custom_save_vars(save_flags)
	. = ..()
	if(track == SOLAR_TRACK_TIMED)
		.[NAMEOF(src, azimuth_rate)] = azimuth_rate
		.[NAMEOF(src, azimuth_target)] = azimuth_target
	return .

/obj/machinery/power/solar_control/PersistentInitialize()
	. = ..()
	search_for_connected()
	switch(track)
		if(SOLAR_TRACK_AUTO)
			if(connected_tracker)
				connected_tracker.sun_update(SSsun, SSsun.azimuth)
			else
				track = SOLAR_TRACK_OFF
		if(SOLAR_TRACK_TIMED)
			set_panels(azimuth_target)

/obj/machinery/power/emitter/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, active)
	. += NAMEOF(src, welded)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, projectile_type)
	. += NAMEOF(src, projectile_sound)
	. += NAMEOF(src, fire_rate_mod)
	. += NAMEOF(src, no_shot_counter)
	return .

/obj/machinery/power/emitter/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	if(diskie)
		save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/machinery/power/emitter/PersistentInitialize()
	. = ..()
	diskie = locate(/obj/item/emitter_disk) in contents
	update_appearance()

/obj/structure/reflector/get_save_vars(save_flags)
	. = ..()
	. += NAMEOF(src, rotation_angle)
	. += NAMEOF(src, finished)
	. += NAMEOF(src, can_rotate)
	return .
