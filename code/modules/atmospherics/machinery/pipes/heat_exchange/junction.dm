/obj/machinery/atmospherics/pipe/heat_exchanging/junction
	icon = 'icons/obj/pipes_n_cables/he-junction.dmi'
	icon_state = "pipe11-3"

	name = "junction"
	desc = "A one meter junction that connects regular and heat-exchanging pipe."

	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	dir = SOUTH

	device_type = BINARY

	construction_type = /obj/item/pipe/directional
	pipe_state = "junction"

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/set_init_directions()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = WEST|EAST

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/get_node_connects()
	return list(REVERSE_DIR(dir), dir)

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/is_connectable(obj/machinery/atmospherics/target, given_layer, he_type_check)
	if(dir == get_dir(target, src))
		return ..(target, given_layer, FALSE) //we want a normal pipe instead
	return ..(target, given_layer, TRUE)

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/update_pipe_icon()
	icon_state = "pipe[nodes[1] ? "1" : "0"][nodes[2] ? "1" : "0"]-[piping_layer]"

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/layer2
	piping_layer = 2
	icon_state = "pipe11-2"

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/layer4
	piping_layer = 4
	icon_state = "pipe11-4"
