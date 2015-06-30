/obj/machinery/atmospherics/components/binary
	icon = 'icons/obj/atmospherics/binary_devices.dmi'
	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	use_power = 1
	nodes = 2

	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2

	var/datum/pipeline/parent1
	var/datum/pipeline/parent2

/obj/machinery/atmospherics/components/binary/New()
	var/airs[] = ..()
	set_airs(airs)

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

/obj/machinery/atmospherics/components/trinary/get_airs()
	return list(air1, air2)

/obj/machinery/atmospherics/components/trinary/get_nodes()
	return list(node1, node2)

/obj/machinery/atmospherics/components/trinary/get_parents()
	return list(parent1, parent2)

/obj/machinery/atmospherics/components/trinary/set_airs(var/list/L)
	var/datum/gas_mixture/a1 = L[1]
	var/datum/gas_mixture/a2 = L[2]

	air1 = a1
	air2 = a2

/obj/machinery/atmospherics/components/trinary/set_nodes(var/list/L)
	var/obj/machinery/atmospherics/n1 = L[1]
	var/obj/machinery/atmospherics/n2 = L[2]

	node1 = n1
	node2 = n2

/obj/machinery/atmospherics/components/trinary/set_parents(var/list/L)
	var/datum/pipeline/p1 = L[1]
	var/datum/pipeline/p2 = L[2]

	parent1 = p1
	parent2 = p2

/*
Housekeeping and pipe network stuff
*/

/obj/machinery/atmospherics/components/binary/atmosinit()

	var/node2_connect = dir
	var/node1_connect = turn(dir, 180)

	//var/node_connects[] = list(node1_connect, node2_connect)
	for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[node1] = target
			break
	for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
		if(target.initialize_directions & get_dir(target,src))
			nodes[node2] = target
			break
	..(/*node_connects*/)

/obj/machinery/atmospherics/components/binary/construction()
	var/parents[] = ..()
	set_parents(parents)

/obj/machinery/atmospherics/components/binary/build_network()
	var/parents[] = ..()
	set_parents(parents)

/obj/machinery/atmospherics/components/binary/disconnect(obj/machinery/atmospherics/reference)
	var/parents[] = ..(reference)
	set_parents(parents)

/obj/machinery/atmospherics/components/binary/nullifyPipenet(datum/pipeline/P)
	var/parents[] = ..(P)
	set_parents(parents)

/obj/machinery/atmospherics/components/binary/setPipenet(datum/pipeline/P, obj/machinery/atmospherics/A)
	var/parents[] = ..(P, A)
	set_parents(parents)

/obj/machinery/atmospherics/components/binary/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	var/parents[] = ..(Old, New)
	set_parents(parents)

/obj/machinery/atmospherics/components/binary/unsafe_pressure_release(var/mob/user, var/pressures)
	var/airs[] = ..(user, pressures)
	set_airs(airs)

//This sure looks like a lot of copypaste... It's already WAY better though, so it works for now
//TODO: make it even more OOP - duncathan