/obj/machinery/atmospherics/components/binary
	icon = 'icons/obj/atmospherics/binary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	use_power = 1
	node_amount = 2

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
/obj/machinery/atmospherics/components/binary/hide(var/intact)
	showpipe = !intact
	update_icon()

	..(intact)
/*
Helpers
*/

/obj/machinery/atmospherics/components/trinary/update_airs(var/a1, var/a2)
	..(list(1 = a1, 2 = a2))

/*
Housekeeping and pipe network stuff
*/

/obj/machinery/atmospherics/components/binary/atmosinit()

	var/node2_connect = dir
	var/node1_connect = turn(dir, 180)

	var/node_connects[] = list(1 = node1_connect, 2 = node2_connect)
	/* for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[1] = target
			break
	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[2] = target
			break */
	..(node_connects)