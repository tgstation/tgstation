/obj/machinery/power/smes/get_save_vars()
	. = ..()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, capacity)
	. += NAMEOF(src, input_level)
	. += NAMEOF(src, output_level)

/obj/machinery/power/apc/get_save_vars()
	. = ..()
	if(!auto_name)
		. -= NAMEOF(src, name)
	. += NAMEOF(src, opened)
	. += NAMEOF(src, coverlocked)
	. += NAMEOF(src, lighting)
	. += NAMEOF(src, equipment)
	. += NAMEOF(src, environ)

	. += NAMEOF(src, cell_type)
	if(cell_type)
		start_charge = cell.charge / cell.maxcharge // only used in Initialize() so direct edit is fine
		. += NAMEOF(src, start_charge)

	// TODO save the wire data but need to include states for cute wires, signalers attached to wires, etc.

/obj/machinery/portable_atmospherics/get_save_vars()
	. = ..()
	var/datum/gas_mixture/gasmix = air_contents
	initial_gas_mix = gasmix.to_string()
	. += NAMEOF(src, initial_gas_mix)

/obj/machinery/portable_atmospherics/canister/get_save_vars()
	. = ..()
	. += NAMEOF(src, valve_open)
	. += NAMEOF(src, release_pressure)

/obj/machinery/atmospherics/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)

/obj/machinery/atmospherics/components/get_save_vars()
	. = ..()
	if(!override_naming)
		// Prevents saving the dynamic name with \proper due to it converting to "???"
		. -= NAMEOF(src, name)
	. += NAMEOF(src, welded)

/obj/machinery/airalarm/get_save_vars()
	. = ..()
	. -= NAMEOF(src, name)

/obj/machinery/door/poddoor/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)

/obj/machinery/door/password/get_save_vars()
	. = ..()
	. += NAMEOF(src, password)

/obj/machinery/door/get_save_vars()
	. = ..()
	. += NAMEOF(src, welded)

/obj/machinery/door/airlock/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state) // airlocks ignore icon_state and instead use get_airlock_overlay()
	// TODO save the wire data but need to include states for cute wires, signalers attached to wires, etc.

/obj/machinery/button/get_save_vars()
	. = ..()
	. += NAMEOF(src, id)
