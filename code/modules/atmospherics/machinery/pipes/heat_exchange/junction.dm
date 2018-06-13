/obj/machinery/atmospherics/pipe/heat_exchanging/junction
	icon = 'icons/obj/atmospherics/pipes/junction.dmi'
	icon_state = "intact"

	name = "junction"
	desc = "A one meter junction that connects regular and heat-exchanging pipe."

	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	dir = SOUTH

	device_type = BINARY

	construction_type = /obj/item/pipe/directional
	pipe_state = "junction"

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/layer1
	piping_layer = PIPING_LAYER_MIN
	pixel_x = -PIPING_LAYER_P_X
	pixel_y = -PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/layer3
	piping_layer = PIPING_LAYER_MAX
	pixel_x = PIPING_LAYER_P_X
	pixel_y = PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/SetInitDirections()
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST,WEST)
			initialize_directions = WEST|EAST

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/getNodeConnects()
	return list(turn(dir, 180), dir)

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/isConnectable(obj/machinery/atmospherics/target, given_layer, he_type_check)
	if(dir == get_dir(target, src))
		return ..(target, given_layer, FALSE)							//we want a normal pipe instead
	return ..(target, given_layer, TRUE)
