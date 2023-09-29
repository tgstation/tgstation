/obj/machinery/atmospherics/components/trinary
	icon = 'icons/obj/machines/atmospherics/trinary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	device_type = TRINARY
	layer = GAS_FILTER_LAYER
	pipe_flags = PIPING_ONE_PER_TURF
	vent_movement = NONE

	///Flips the node connections so that the first and third ports are swapped
	var/flipped = FALSE

/obj/machinery/atmospherics/components/trinary/set_init_directions()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|WEST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|SOUTH
		if(WEST)
			initialize_directions = WEST|NORTH|EAST

/*
Housekeeping and pipe network stuff
*/

/obj/machinery/atmospherics/components/trinary/get_node_connects()

	//Mixer:
	//1 and 2 is input
	//Node 3 is output
	//If we flip the mixer, 1 and 3 shall exchange positions

	//Filter:
	//Node 1 is input
	//Node 2 is filtered output
	//Node 3 is rest output
	//If we flip the filter, 1 and 3 shall exchange positions

	var/node1_connect = REVERSE_DIR(dir)
	var/node2_connect = turn(dir, -90)
	var/node3_connect = dir

	if(flipped)
		node1_connect = REVERSE_DIR(node1_connect)
		node3_connect = REVERSE_DIR(node3_connect)

	return list(node1_connect, node2_connect, node3_connect)

/obj/machinery/atmospherics/components/trinary/proc/set_overlay_offset(pipe_layer)
	switch(pipe_layer)
		if(1)
			return 1
		if(5)
			return 5
		else
			return 0
