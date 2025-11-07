// these spawn underneath apc's but are created by them in Initilization()
/obj/machinery/power/terminal/is_saveable()
	if(locate(/obj/machinery/power/apc) in loc)
		return FALSE

	return ..()

/obj/machinery/power/apc/get_save_vars()
	. = ..()
	. += NAMEOF(src, opened)
	. += NAMEOF(src, coverlocked)
	. += NAMEOF(src, lighting)
	. += NAMEOF(src, equipment)
	. += NAMEOF(src, environ)
	. += NAMEOF(src, cell_type)

	if(auto_name)
		. -= NAMEOF(src, name)

	// TODO save the wire data but need to include states for cute wires, signalers attached to wires, etc.
	//. += NAMEOF(src, shorted)
	//. += NAMEOF(src, locked)
	return .

/obj/machinery/power/apc/get_custom_save_vars()
	. = ..()
	if(cell_type)
		.[NAMEOF(src, start_charge)] = round((cell.charge / cell.maxcharge * 100))
	return .

/obj/machinery/power/smes/get_save_vars()
	. = ..()
	. += NAMEOF(src, input_level)
	. += NAMEOF(src, output_level)
	return .

/obj/machinery/power/smes/get_custom_save_vars()
	. = ..()
	.[NAMEOF(src, charge)] = total_charge()
	return .

/obj/item/stock_parts/power_store/get_save_vars()
	. = ..()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, rigged)
	return .
