/obj/machinery/atmospherics/unary
	dir = SOUTH
	initialize_directions = SOUTH
	layer = 2.45 // Cable says we're at 2.45, so we're at 2.45.  (old: TURF_LAYER+0.1)

	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/node
	var/datum/pipe_network/network

/obj/machinery/atmospherics/unary/New()
	..()
	initialize_directions = dir
	air_contents = new

	air_contents.temperature = T0C
	air_contents.volume = starting_volume

/obj/machinery/atmospherics/unary/update_icon(var/adjacent_procd,node_list)
	node_list = list(node)
	..(adjacent_procd,node_list)

/obj/machinery/atmospherics/unary/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = pipe.get_pipe_dir()
	if (pipe.pipename)
		name = pipe.pipename
	var/turf/T = loc
	level = T.intact ? 2 : 1
	initialize()
	build_network()
	if (node)
		node.initialize()
		node.build_network()
	return 1

// Housekeeping and pipe network stuff below
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
		if(network)
			returnToPool(network)
	node = null
	..()

/obj/machinery/atmospherics/unary/initialize()
	if(node) return
	var/node_connect = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			if(target.piping_layer == piping_layer || target.pipe_flags & ALL_LAYER)
				node = target
				break
	update_icon()

/obj/machinery/atmospherics/unary/build_network()
	if(!network && node)
		network = getFromPool(/datum/pipe_network)
		network.normal_members += src
		network.build_network(node, src)


/obj/machinery/atmospherics/unary/return_network(obj/machinery/atmospherics/reference)
	build_network()
	if(reference == node || reference == src)
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
		if(network)
			returnToPool(network)
		node = null
	return null

/obj/machinery/atmospherics/unary/unassign_network(datum/pipe_network/reference)
	if(network == reference)
		network = null