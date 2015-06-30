/obj/machinery/atmospherics/components/trinary
	icon = 'icons/obj/atmospherics/trinary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = 1
	nodes = 3

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipeline/parent1
	var/datum/pipeline/parent2
	var/datum/pipeline/parent3

	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2
	var/datum/gas_mixture/air3

	var/flipped = 0

/obj/machinery/atmospherics/components/trinary/New()
	var/airs[] = ..()
	set_airs(airs)

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
Helpers //these all look kinda copypaste-y, but I'm not entirely certain how to get around that -duncathan
*/

/obj/machinery/atmospherics/components/trinary/get_airs()
	return list(air1, air2, air3)

/obj/machinery/atmospherics/components/trinary/get_nodes()
	return list(node1, node2, node3)

/obj/machinery/atmospherics/components/trinary/get_parents()
	return list(parent1, parent2, parent3)

/obj/machinery/atmospherics/components/trinary/set_airs(var/list/L)
	var/datum/gas_mixture/a1 = L[1]
	var/datum/gas_mixture/a2 = L[2]
	var/datum/gas_mixture/a3 = L[3]

	air1 = a1
	air2 = a2
	air3 = a3

/obj/machinery/atmospherics/components/trinary/set_nodes(var/list/L)
	var/obj/machinery/atmospherics/n1 = L[1]
	var/obj/machinery/atmospherics/n2 = L[2]
	var/obj/machinery/atmospherics/n3 = L[3]

	node1 = n1
	node2 = n2
	node3 = n3

/obj/machinery/atmospherics/components/trinary/set_parents(var/list/L)
	var/datum/pipeline/p1 = L[1]
	var/datum/pipeline/p2 = L[2]
	var/datum/pipeline/p3 = L[3]

	parent1 = p1
	parent2 = p2
	parent3 = p3

/*
Housekeeping and pipe network stuff
//WOW this got cut down thank you based OOP - duncathan
*/
/obj/machinery/atmospherics/components/trinary/Destroy()
	var/returns[] = ..()

	set_nodes(returns[1])
	set_parents(returns[2])

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

	//var/node_connects[] = list(nodes[node1]_connect, nodes[node2]_connect, nodes[node3]_connect)

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[node1] = target
			break
	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[node2] = target
			break
	for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[node3] = target
			break
	..(/*node_connects*/)

/obj/machinery/atmospherics/components/trinary/construction()
	var/parents[] = ..()
	set_parents(parents)

/obj/machinery/atmospherics/components/trinary/build_network()
	var/parents[] = ..()
	set_parents(parents)

/obj/machinery/atmospherics/components/trinary/disconnect(obj/machinery/atmospherics/reference)
	var/parents[] = ..(reference)
	set_parents(parents)

/obj/machinery/atmospherics/components/trinary/nullifyPipenet(datum/pipeline/P)
	var/parents[] = ..(P)
	set_parents(parents)

/obj/machinery/atmospherics/components/trinary/setPipenet(datum/pipeline/P, obj/machinery/atmospherics/A)
	var/parents[] = ..(P, A)
	set_parents(parents)

/obj/machinery/atmospherics/components/trinary/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	var/parents[] = ..(Old, New)
	set_parents(parents)

/obj/machinery/atmospherics/components/trinary/unsafe_pressure_release(var/mob/user, var/pressures)
	var/airs[] = ..(user, pressures)
	set_airs(airs)

//This sure looks like a lot of copypaste... It's already way better though, so it works for now
//TODO: make it even more OOP - duncathan