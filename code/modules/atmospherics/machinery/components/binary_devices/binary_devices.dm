/obj/machinery/atmospherics/components/binary
	icon = 'icons/obj/machines/atmospherics/binary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.25
	device_type = BINARY
	layer = GAS_PUMP_LAYER
	pipe_flags = PIPING_BRIDGE

/obj/machinery/atmospherics/components/binary/set_init_directions()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/components/binary/get_node_connects()
	return list(REVERSE_DIR(dir), dir)

/**
 * Used by binary devices to set what the offset will be for each layer, called in update_icon_nopipes()
 * Arguments:
 * * -pipe_layer: is the pipe layer the component should be set to
 */
/obj/machinery/atmospherics/components/binary/proc/set_overlay_offset(pipe_layer)
	switch(pipe_layer)
		if(1, 3, 5)
			return 1
		if(2, 4)
			return 2
