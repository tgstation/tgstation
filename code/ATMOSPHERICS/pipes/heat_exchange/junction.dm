/obj/machinery/atmospherics/pipe/heat_exchanging/junction
	icon = 'icons/obj/atmospherics/pipes/junction.dmi'
	icon_state = "intact"

	name = "junction"
	desc = "A one meter junction that connects regular and heat-exchanging pipe"

	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	volume = 70

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

/obj/machinery/atmospherics/pipe/heat_exchanging/junction/atmosinit() //it pains me that this must be hardcoded, but the alternative is super hacky
	for(var/obj/machinery/atmospherics/target in get_step(src,initialize_directions))
		if(target.initialize_directions & get_dir(target,src))
			NODE1 = target
			break
	for(var/obj/machinery/atmospherics/pipe/heat_exchanging/simple/target in get_step(src,initialize_directions_he))
		if(target.initialize_directions_he & get_dir(target,src))
			NODE2 = target
			break
	update_icon()