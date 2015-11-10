/obj/machinery/atmospherics/components/binary
	icon = 'icons/obj/atmospherics/components/binary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	use_power = 1
	device_type = BINARY

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

/obj/machinery/atmospherics/components/binary/atmosinit()
	var/node2_connect = dir
	var/node1_connect = turn(dir, 180)

	var/list/node_connects = list(node1_connect, node2_connect)
	..(node_connects)