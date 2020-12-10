/obj/machinery/atmospherics/pipe/heat_exchanging/junction
	icon = 'icons/obj/atmospherics/pipes/he-junction.dmi'
	icon_state = "pipe11-3"

	name = "junction"
	desc = "A one meter junction that connects regular and heat-exchanging pipe."

	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	dir = SOUTH

	device_type = BINARY

	construction_type = /obj/item/pipe/directional
	pipe_state = "junction"
	var/mutable_appearance/center

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/Initialize()
	. = ..()
	icon_state = ""
	center = mutable_appearance(icon, "pipe11")
	update_icon()

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/SetInitDirections()
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = WEST|EAST

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/getNodeConnects()
	return list(turn(dir, 180), dir)

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/isConnectable(obj/machinery/atmospherics/target, given_layer, he_type_check)
	if(dir == get_dir(target, src))
		return ..(target, given_layer, FALSE) //we want a normal pipe instead
	return ..(target, given_layer, TRUE)

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/update_icon()
	cut_overlays()
	if(!center)
		if(nodes[1] && nodes[2])
			center = mutable_appearance(icon, "pipe11")
		else if(nodes[1] && !nodes[2])
			center = mutable_appearance(icon, "pipe10")
		else if(!nodes[1] && nodes[2])
			center = mutable_appearance(icon, "pipe01")
		else
			center = mutable_appearance(icon, "pipe00")
	PIPING_LAYER_DOUBLE_SHIFT(center, piping_layer)
	add_overlay(center)
	if(nodes[1])
		var/obj/machinery/atmospherics/overlay = getpipeimage(icon, "pipe", get_dir(src, nodes[1]))
		PIPING_LAYER_DOUBLE_SHIFT(overlay, piping_layer)
		add_overlay(overlay)
	update_layer()

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/layer2
	piping_layer = 2
	icon_state = "pipe11-2"

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/layer4
	piping_layer = 4
	icon_state = "pipe11-4"
