/obj/machinery/atmospherics/pipe/heat_exchanging/junction
	icon = 'icons/obj/atmospherics/pipes/junction.dmi'
	icon_state = "intact"

	name = "junction"
	desc = "A one meter junction that connects regular and heat-exchanging pipe"

	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	dir = SOUTH
	initialize_directions = NORTH
	initialize_directions_he = SOUTH

	device_type = BINARY

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/SetInitDirections()
	switch(dir)
		if(SOUTH)
			initialize_directions = NORTH
			initialize_directions_he = SOUTH
		if(NORTH)
			initialize_directions = SOUTH
			initialize_directions_he = NORTH
		if(EAST)
			initialize_directions = WEST
			initialize_directions_he = EAST
		if(WEST)
			initialize_directions = EAST
			initialize_directions_he = WEST

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/atmosinit()
	var/node2_connect = dir
	var/node1_connect = turn(dir, 180)
	var/list/node_connects = list(node1_connect, node2_connect)

	..(node_connects)

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/can_be_node(obj/machinery/atmospherics/target, iteration)
	var/init_dir
	switch(iteration)
		if(1)
			init_dir = target.initialize_directions
		if(2)
			var/obj/machinery/atmospherics/pipe/heat_exchanging/H = target
			if(!istype(H))
				return 0
			init_dir = H.initialize_directions_he
	if(init_dir & get_dir(target,src))
		return 1