obj/machinery/water/binary
	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	var/datum/reagents/r1
	var/datum/reagents/r2

	var/obj/machinery/water/node1
	var/obj/machinery/water/node2

	var/datum/water/pipe_network/network1
	var/datum/water/pipe_network/network2

	var/max_volume = 400
	var/max_pressure = 3 * ONE_ATMOSPHERE

	New()
		..()
		switch(dir)
			if(NORTH)
				initialize_directions = NORTH|SOUTH
			if(SOUTH)
				initialize_directions = NORTH|SOUTH
			if(EAST)
				initialize_directions = EAST|WEST
			if(WEST)
				initialize_directions = EAST|WEST
		r1 = new(max_volume)
		r1.my_atom = src
		r2 = new(max_volume)
		r2.my_atom = src

// Housekeeping and pipe network stuff below
	network_expand(datum/water/pipe_network/new_network, obj/machinery/water/pipe/reference)
		if(reference == node1)
			network1 = new_network

		else if(reference == node2)
			network2 = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null

	Del()
		loc = null

		if(node1)
			node1.disconnect(src)
			del(network1)
		if(node2)
			node2.disconnect(src)
			del(network2)

		node1 = null
		node2 = null

		..()

	initialize()
		if(node1 && node2) return

		var/node2_connect = dir
		var/node1_connect = turn(dir, 180)

		for(var/obj/machinery/water/target in get_step(src,node1_connect))
			if(target.initialize_directions & get_dir(target,src))
				node1 = target
				break

		for(var/obj/machinery/water/target in get_step(src,node2_connect))
			if(target.initialize_directions & get_dir(target,src))
				node2 = target
				break

		update_icon()

	build_network()
		if(!network1 && node1)
			network1 = new /datum/water/pipe_network()
			network1.normal_members += src
			network1.build_network(node1, src)

		if(!network2 && node2)
			network2 = new /datum/water/pipe_network()
			network2.normal_members += src
			network2.build_network(node2, src)


	return_network(obj/machinery/water/reference)
		build_network()

		if(reference==node1)
			return network1

		if(reference==node2)
			return network2

		return null

	reassign_network(datum/water/pipe_network/old_network, datum/water/pipe_network/new_network)
		if(network1 == old_network)
			network1 = new_network
		if(network2 == old_network)
			network2 = new_network

		return 1

	return_network_reagents(datum/water/pipe_network/reference)
		var/list/results = list()

		if(network1 == reference)
			results += r1
		if(network2 == reference)
			results += r2

		return results

	disconnect(obj/machinery/water/reference)
		if(reference==node1)
			del(network1)
			node1 = null

		else if(reference==node2)
			del(network2)
			node2 = null

		return null

	proc/return_pressure1()
		return r1.total_volume / r1.maximum_volume * max_pressure

	proc/return_pressure2()
		return r2.total_volume / r2.maximum_volume * max_pressure

	proc/mingle_dc1_with_turf()
		mingle_outflow_with_turf(get_turf(src), r1.total_volume,
			turn(dir,  180),
			reagents = r1, pressure = return_pressure1())

	proc/mingle_dc2_with_turf()
		mingle_outflow_with_turf(get_turf(src), r2.total_volume,
			dir,
			reagents = r2, pressure = return_pressure2())