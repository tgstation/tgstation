obj/machinery/atmospherics/mixer
	icon = 'mixer.dmi'
	icon_state = "intact_off"
	density = 1

	name = "Gas mixer"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	req_access = list(access_atmospherics)

	var/on = 0

	var/datum/gas_mixture/air_in1
	var/datum/gas_mixture/air_in2
	var/datum/gas_mixture/air_out

	var/obj/machinery/atmospherics/node_in1
	var/obj/machinery/atmospherics/node_in2
	var/obj/machinery/atmospherics/node_out

	var/datum/pipe_network/network_in1
	var/datum/pipe_network/network_in2
	var/datum/pipe_network/network_out

	var/target_pressure = ONE_ATMOSPHERE
	var/node1_concentration = 0.5
	var/node2_concentration = 0.5

	update_icon()
		if(node_in1&&node_in2&&node_out)
			icon_state = "intact_[on?("on"):("off")]"
		else
			var/node_in1_direction = get_dir(src, node_in1)
			var/node_in2_direction = get_dir(src, node_in2)

			var/node_out_bit = (node_out)?(1):(0)

			icon_state = "exposed_[node_in1_direction|node_in2_direction]_[node_out_bit]_off"

			on = 0

		return

	New()
		..()
		switch(dir)
			if(NORTH)
				initialize_directions = NORTH|EAST|SOUTH
			if(EAST)
				initialize_directions = EAST|SOUTH|WEST
			if(SOUTH)
				initialize_directions = SOUTH|WEST|NORTH
			if(WEST)
				initialize_directions = WEST|NORTH|EAST
		air_in1 = new
		air_in2 = new
		air_out = new

		air_in1.volume = 200
		air_in2.volume = 200
		air_out.volume = 300

	process()
		..()
		if(!on)
			return 0

		var/output_starting_pressure = air_out.return_pressure()

		if(output_starting_pressure >= target_pressure)
			//No need to mix if target is already full!
			return 1

		//Calculate necessary moles to transfer using PV=nRT

		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles1 = 0
		var/transfer_moles2 = 0

		if(air_in1.temperature > 0)
			transfer_moles1 = (node1_concentration*pressure_delta)*air_out.volume/(air_in1.temperature * R_IDEAL_GAS_EQUATION)

		if(air_in2.temperature > 0)
			transfer_moles2 = (node2_concentration*pressure_delta)*air_out.volume/(air_in2.temperature * R_IDEAL_GAS_EQUATION)

		var/air_in1_moles = air_in1.total_moles()
		var/air_in2_moles = air_in2.total_moles()

		if((air_in1_moles < transfer_moles1) || (air_in2_moles < transfer_moles2))
			var/ratio = min(air_in1_moles/transfer_moles1, air_in2_moles/transfer_moles2)

			transfer_moles1 *= ratio
			transfer_moles2 *= ratio

		//Actually transfer the gas

		if(transfer_moles1 > 0)
			var/datum/gas_mixture/removed1 = air_in1.remove(transfer_moles1)
			air_out.merge(removed1)

		if(transfer_moles2 > 0)
			var/datum/gas_mixture/removed2 = air_in2.remove(transfer_moles2)
			air_out.merge(removed2)

		if(network_in1 && transfer_moles1)
			network_in1.update = 1

		if(network_in2 && transfer_moles2)
			network_in2.update = 1

		if(network_out)
			network_out.update = 1

		return 1

// Housekeeping and pipe network stuff below
	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node_in1)
			network_in1 = new_network

		else if(reference == node_in2)
			network_in2 = new_network

		else if(reference == node_out)
			network_out = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null

	Del()
		loc = null

		if(node_in1)
			node_in1.disconnect(src)
			del(network_in1)

		if(node_in2)
			node_in2.disconnect(src)
			del(network_in2)

		if(node_out)
			node_out.disconnect(src)
			del(network_out)

		node_in1 = null
		node_in2 = null
		node_out = null

		..()

	initialize()
		if(node_in1 && node_out) return

		var/node_out_connect = dir
		var/node_in1_connect = turn(dir, -90)
		var/node_in2_connect = turn(dir, -180)

		for(var/obj/machinery/atmospherics/target in get_step(src,node_in1_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_in1 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node_in2_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_in2 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node_out_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_out = target
				break

		update_icon()

	build_network()
		if(!network_in1 && node_in1)
			network_in1 = new /datum/pipe_network()
			network_in1.normal_members += src
			network_in1.build_network(node_in1, src)

		if(!network_in2 && node_in2)
			network_in2 = new /datum/pipe_network()
			network_in2.normal_members += src
			network_in2.build_network(node_in2, src)

		if(!network_out && node_out)
			network_out = new /datum/pipe_network()
			network_out.normal_members += src
			network_out.build_network(node_out, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node_in1)
			return network_in1

		if(reference==node_in2)
			return network_in2

		if(reference==node_out)
			return network_out

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network_in1 == old_network)
			network_in1 = new_network

		if(network_in2 == old_network)
			network_in2 = new_network

		if(network_out == old_network)
			network_out = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(network_in1 == reference)
			results += air_in1

		if(network_in2 == reference)
			results += air_in2

		if(network_out == reference)
			results += air_out

		return results

	disconnect(obj/machinery/atmospherics/reference)
		if(reference==node_in1)
			del(network_in1)
			node_in1 = null

		else if(reference==node_in2)
			del(network_in2)
			node_in2 = null

		else if(reference==node_out)
			del(network_out)
			node_out = null

		return null


	attack_hand(user as mob)
		if(..())
			return
		src.add_fingerprint(usr)
		if(!src.allowed(user))
			user << "\red Access denied."
			return
		usr.machine = src
		var/dat = {"<b>Power: </b><a href='?src=\ref[src];power=1'>[on?"On":"Off"]</a><br>
					<b>Desirable output pressure: </b>
					<a href='?src=\ref[src];out_press=-100'><b>-</b></a>
					<a href='?src=\ref[src];out_press=-10'><b>-</b></a>
					<a href='?src=\ref[src];out_press=-1'>-</a>
					[target_pressure]kPa
					<a href='?src=\ref[src];out_press=1'>+</a>
					<a href='?src=\ref[src];out_press=10'><b>+</b></a>
					<a href='?src=\ref[src];out_press=100'><b>+</b></a>
					<br>
					<b>Node 1 Concentration:</b>
					<a href='?src=\ref[src];node1_c=-0.1'><b>-</b></a>
					<a href='?src=\ref[src];node1_c=-0.01'>-</a>
					[node1_concentration]([node1_concentration*100]%)
					<a href='?src=\ref[src];node1_c=0.01'><b>+</b></a>
					<a href='?src=\ref[src];node1_c=0.1'>+</a>
					<br>
					<b>Node 2 Concentration:</b>
					<a href='?src=\ref[src];node2_c=-0.1'><b>-</b></a>
					<a href='?src=\ref[src];node2_c=-0.01'>-</a>
					[node2_concentration]([node2_concentration*100]%)
					<a href='?src=\ref[src];node2_c=0.01'><b>+</b></a>
					<a href='?src=\ref[src];node2_c=0.1'>+</a>
					"}

		user << browse("<HEAD><TITLE>[src.name] control</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_mixer")
		onclose(user, "atmo_mixer")
		return

	Topic(href,href_list)
		if(href_list["power"])
			on = !on
		if(href_list["out_press"])
			src.target_pressure = max(0, min(4500, src.target_pressure + text2num(href_list["out_press"])))
		if(href_list["node1_c"])
			var/value = text2num(href_list["node1_c"])
			src.node1_concentration = max(0, min(1, src.node1_concentration + value))
			src.node2_concentration = max(0, min(1, src.node2_concentration - value))
		if(href_list["node2_c"])
			var/value = text2num(href_list["node2_c"])
			src.node2_concentration = max(0, min(1, src.node2_concentration + value))
			src.node1_concentration = max(0, min(1, src.node1_concentration - value))
		src.update_icon()
		src.updateUsrDialog()
		return
