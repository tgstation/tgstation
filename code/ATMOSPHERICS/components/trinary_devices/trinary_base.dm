/obj/machinery/atmospherics/components/trinary
	icon = 'icons/obj/atmospherics/trinary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = 1
	node_amount = 3

	var/flipped = 0

/obj/machinery/atmospherics/components/trinary/SetInitDirections()
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
Helpers
*/

/obj/machinery/atmospherics/components/trinary/update_airs(var/a1, var/a2, var/a3)
	..(list(1 = a1, 2 = a2, 3 = a3))
/*
/obj/machinery/atmospherics/components/trinary/set_nodes(var/list/L)
	var/obj/machinery/atmospherics/n1 = L[1]
	var/obj/machinery/atmospherics/n2 = L[2]
	var/obj/machinery/atmospherics/n3 = L[3]

	node1 = n1
	node2 = n2
	node3 = n3
*/


/*
Housekeeping and pipe network stuff
//WOW this got cut down thank you based OOP - duncathan
*/

/obj/machinery/atmospherics/components/trinary/atmosinit()

	//Mixer:
	//1 and 2 is input
	//Node 3 is output
	//If we flip the mixer, 1 and 3 shall exchange positions

	//Filter:
	//Node 1 is input
	//Node 2 is filtered output
	//Node 3 is rest output
	//If we flip the filter, 1 and 3 shall exchange positions

	var/node1_connect = turn(dir, -180)
	var/node2_connect = turn(dir, -90)
	var/node3_connect = dir

	if(flipped)
		node1_connect = turn(node1_connect, 180)
		node3_connect = turn(node3_connect, 180)

	var/node_connects[] = list(1 = node1_connect, 2 = node2_connect, 3 = node3_connect)

	/* for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[1] = target
			break
	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[2] = target
			break
	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[3] = target
			break */
	..(node_connects)