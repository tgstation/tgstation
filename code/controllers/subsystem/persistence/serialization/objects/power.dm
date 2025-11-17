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

// these spawn underneath apc's but are created by them in initialization
/obj/machinery/power/terminal/is_saveable(turf/current_loc, list/obj_blacklist)
	if(locate(/obj/machinery/power/apc) in loc)
		return FALSE

	return ..()

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
	//. += NAMEOF(src, locked)
	return .

/obj/machinery/power/apc/get_custom_save_vars(save_flags=ALL)
	. = ..()
	if(cell_type)
		.[NAMEOF(src, start_charge)] = round((cell.charge / cell.maxcharge * 100))
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
