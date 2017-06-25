/obj/machinery/atmospherics/components/binary
	icon = 'icons/obj/atmospherics/components/binary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	use_power = 1
	device_type = BINARY
	layer = GAS_PUMP_LAYER

/obj/machinery/atmospherics/components/binary/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = NORTH|SOUTH
		if(SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST)
			initialize_directions = EAST|WEST
		if(WEST)
			initialize_directions = EAST|WEST
/*
Iconnery
*/
/obj/machinery/atmospherics/components/binary/hide(intact)
	update_icon()

	..(intact)
/*
Housekeeping and pipe network stuff
*/

/obj/machinery/atmospherics/components/binary/getNodeConnects()
	return list(turn(dir, 180), dir)
