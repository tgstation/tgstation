/obj/machinery/water/unary
	dir = SOUTH
	initialize_directions = SOUTH

	var/obj/machinery/water/node
	var/datum/water/pipe_network/network

	var/max_volume = 400
	var/max_pressure = 3 * ONE_ATMOSPHERE

	New()
		..()
		initialize_directions = dir
		reagents = new(max_volume)
		reagents.my_atom = src

	proc/return_pressure()
		return reagents.total_volume / reagents.maximum_volume * max_pressure

// Housekeeping and pipe network stuff below
	network_expand(datum/water/pipe_network/new_network, obj/machinery/water/pipe/reference)
		if(reference == node)
			network = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null

	Del()
		loc = null

		if(node)
			node.disconnect(src)
			del(network)

		node = null

		..()

	initialize()
		if(node) return

		var/node_connect = dir

		for(var/obj/machinery/water/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

		update_icon()

	build_network()
		if(!network && node)
			network = new /datum/water/pipe_network()
			network.normal_members += src
			network.build_network(node, src)


	return_network(obj/machinery/water/reference)
		build_network()

		if(reference==node)
			return network

		return null

	reassign_network(datum/water/pipe_network/old_network, datum/water/pipe_network/new_network)
		if(network == old_network)
			network = new_network

		return 1

	return_network_reagents(datum/water/pipe_network/reference)
		var/list/results = list()

		if(network == reference)
			results += reagents

		return results

	disconnect(obj/machinery/water/reference)
		if(reference==node)
			del(network)
			node = null

		return null