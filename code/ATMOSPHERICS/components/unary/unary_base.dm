/obj/machinery/atmospherics/unary
	icon = 'icons/obj/atmospherics/unary_devices.dmi'

	dir = SOUTH
	initialize_directions = SOUTH
	layer = TURF_LAYER+0.1

	var/datum/gas_mixture/air_contents

	var/obj/machinery/atmospherics/node

	var/datum/pipe_network/network

	var/showpipe = 0

/obj/machinery/atmospherics/unary/New()
	..()
	initialize_directions = dir
	air_contents = new

	air_contents.volume = 200

/*
Iconnery
*/
//Separate this because we don't need to update pipe icons if we just are going to change the state
/obj/machinery/atmospherics/unary/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/unary/update_icon()
	update_icon_nopipes()

	//This code might be a bit specific to scrubber, vents and injectors, but honestly they are basically the only ones used in the unary branch.

	underlays.Cut()

	if(showpipe)
		var/state
		var/col
		if(node)
			state = "pipe_intact"
			col = node.pipe_color
		else
			state = "pipe_exposed"

		underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', state, initialize_directions, col)

/obj/machinery/atmospherics/unary/hide(var/intact)
	showpipe = !intact
	update_icon()

	..(intact)

/*
Housekeeping and pipe network stuff below
*/
/obj/machinery/atmospherics/unary/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node)
		network = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	return null

/obj/machinery/atmospherics/unary/Destroy()
	if(node)
		node.disconnect(src)
		del(network)

	node = null

	..()

/obj/machinery/atmospherics/unary/initialize(infiniteloop = 0)
	if(!infiniteloop)
		src.disconnect(src)

	var/node_connect = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			if(!infiniteloop)
				target.initialize(1)
			break
	//build_network() might need this

	if(level == 2)
		showpipe = 1

	update_icon()

/obj/machinery/atmospherics/unary/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(..())
		initialize_directions = dir
		if(node)
			disconnect(node)
		initialize()
		. = 1

/obj/machinery/atmospherics/unary/build_network()
	if(!network && node)
		network = new /datum/pipe_network()
		network.normal_members += src
		network.build_network(node, src)


/obj/machinery/atmospherics/unary/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node)
		return network

	return null

/obj/machinery/atmospherics/unary/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network == old_network)
		network = new_network

	return 1

/obj/machinery/atmospherics/unary/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(network == reference)
		results += air_contents

	return results

/obj/machinery/atmospherics/unary/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node)
		node = null
		reference.disconnect(src)
		del(network)

	update_icon()

	return null

/obj/machinery/atmospherics/unary/nullifyPipenetwork()
	network = null