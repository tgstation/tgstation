obj/machinery/atmospherics/trinary
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = 1

	var/datum/gas_mixture/air1
	var/datum/gas_mixture/air2
	var/datum/gas_mixture/air3

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipe_network/network1
	var/datum/pipe_network/network2
	var/datum/pipe_network/network3

	New()
		..()
		switch(dir)
			if(NORTH)
				initialize_directions = EAST|NORTH|SOUTH
			if(SOUTH)
				initialize_directions = SOUTH|WEST|NORTH
			if(EAST)
				initialize_directions = EAST|WEST|SOUTH
			if(WEST)
				initialize_directions = WEST|NORTH|EAST
		air1 = new
		air2 = new
		air3 = new

		air1.volume = 200
		air2.volume = 200
		air3.volume = 200

// Housekeeping and pipe network stuff below
	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node1)
			network1 = new_network

		else if(reference == node2)
			network2 = new_network

		else if (reference == node3)
			network3 = new_network

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
		if(node3)
			node3.disconnect(src)
			del(network3)

		node1 = null
		node2 = null
		node3 = null

		..()

	initialize()
		if(node1 && node2 && node3) return

		var/node1_connect = turn(dir, -180)
		var/node2_connect = turn(dir, -90)
		var/node3_connect = dir

		for(var/obj/machinery/atmospherics/target in get_step(src,node1_connect))
			if(target.initialize_directions & get_dir(target,src))
				node1 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node2_connect))
			if(target.initialize_directions & get_dir(target,src))
				node2 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node3_connect))
			if(target.initialize_directions & get_dir(target,src))
				node3 = target
				break

		update_icon()

	build_network()
		if(!network1 && node1)
			network1 = new /datum/pipe_network()
			network1.normal_members += src
			network1.build_network(node1, src)

		if(!network2 && node2)
			network2 = new /datum/pipe_network()
			network2.normal_members += src
			network2.build_network(node2, src)

		if(!network3 && node3)
			network3 = new /datum/pipe_network()
			network3.normal_members += src
			network3.build_network(node3, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node1)
			return network1

		if(reference==node2)
			return network2

		if(reference==node3)
			return network3

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network1 == old_network)
			network1 = new_network
		if(network2 == old_network)
			network2 = new_network
		if(network3 == old_network)
			network3 = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(network1 == reference)
			results += air1
		if(network2 == reference)
			results += air2
		if(network3 == reference)
			results += air3

		return results

	disconnect(obj/machinery/atmospherics/reference)
		if(reference==node1)
			del(network1)
			node1 = null

		else if(reference==node2)
			del(network2)
			node2 = null

		else if(reference==node3)
			del(network3)
			node3 = null

		return null