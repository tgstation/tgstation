obj/machinery/atmospherics/filter
	icon = 'filter.dmi'
	icon_state = "intact_off"
	density = 1

	name = "Gas filter"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST

	var/on = 0
	var/temp = null // -- TLE

	var/datum/gas_mixture/air_in
	var/datum/gas_mixture/air_out1
	var/datum/gas_mixture/air_out2

	var/obj/machinery/atmospherics/node_in
	var/obj/machinery/atmospherics/node_out1
	var/obj/machinery/atmospherics/node_out2

	var/datum/pipe_network/network_in
	var/datum/pipe_network/network_out1
	var/datum/pipe_network/network_out2

	var/target_pressure = ONE_ATMOSPHERE

	var/filter_type = 0
/*
Filter types:
0: Carbon Molecules: Plasma Toxin, Carbon Dioxide, Oxygen Agent B
1: Oxygen: Oxygen ONLY
2: Nitrogen: Nitrogen and Sleeping Agent
3: Carbon Dioxide: Carbon Dioxide ONLY
*/

	var/frequency = 0
	var/datum/radio_frequency/radio_connection

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, "[frequency]")

	New()
		..()
		switch(dir)
			if(NORTH)
				initialize_directions = NORTH|EAST|SOUTH
			if(SOUTH)
				initialize_directions = NORTH|SOUTH|WEST
			if(EAST)
				initialize_directions = EAST|WEST|SOUTH
			if(WEST)
				initialize_directions = NORTH|EAST|WEST
		if(radio_controller)
			initialize()

	update_icon()
		if(node_out1&&node_out2&&node_in)
			icon_state = "intact_[on?("on"):("off")]"
		else
			var/node_out1_direction = get_dir(src, node_out1)
			var/node_out2_direction = get_dir(src, node_out2)

			var/node_in_bit = (node_in)?(1):(0)

			icon_state = "exposed_[node_out1_direction|node_out2_direction]_[node_in_bit]_off"

			on = 0

		return

	New()
		..()

		air_in = new
		air_out1 = new
		air_out2 = new

		air_in.volume = 200
		air_out1.volume = 200
		air_out2.volume = 200

	process()
		..()
		if(!on)
			return 0

		var/output_starting_pressure = air_out2.return_pressure()

		if(output_starting_pressure >= target_pressure)
			//No need to mix if target is already full!
			return 1

		//Calculate necessary moles to transfer using PV=nRT

		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles

		if(air_in.temperature > 0)
			transfer_moles = pressure_delta*air_out2.volume/(air_in.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas

		if(transfer_moles > 0)
			var/datum/gas_mixture/removed = air_in.remove(transfer_moles)

			var/datum/gas_mixture/filtered_out = new
			filtered_out.temperature = removed.temperature

			switch(filter_type)
				if(0) //removing hydrocarbons
					filtered_out.toxins = removed.toxins
					removed.toxins = 0

					filtered_out.carbon_dioxide = removed.carbon_dioxide
					removed.carbon_dioxide = 0

					if(removed.trace_gases.len>0)
						for(var/datum/gas/trace_gas in removed.trace_gases)
							if(istype(trace_gas, /datum/gas/oxygen_agent_b))
								removed.trace_gases -= trace_gas
								filtered_out.trace_gases += trace_gas

				if(1) //removing O2
					filtered_out.oxygen = removed.oxygen
					removed.oxygen = 0

				if(2) //removing N2
					filtered_out.nitrogen = removed.nitrogen
					removed.nitrogen = 0

					if(removed.trace_gases.len>0)
						for(var/datum/gas/trace_gas in removed.trace_gases)
							if(istype(trace_gas, /datum/gas/sleeping_agent))
								removed.trace_gases -= trace_gas
								filtered_out.trace_gases += trace_gas

				if(3) //removing CO2
					filtered_out.carbon_dioxide = removed.carbon_dioxide
					removed.carbon_dioxide = 0


			air_out1.merge(filtered_out)
			air_out2.merge(removed)

		if(network_out1)
			network_out1.update = 1

		if(network_out2)
			network_out2.update = 1

		if(network_in)
			network_in.update = 1

		return 1

// Housekeeping and pipe network stuff below
	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node_out1)
			network_out1 = new_network

		else if(reference == node_out2)
			network_out2 = new_network

		else if(reference == node_in)
			network_in = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null

	Del()
		loc = null

		if(node_out1)
			node_out1.disconnect(src)
			del(network_out1)

		if(node_out2)
			node_out2.disconnect(src)
			del(network_out2)

		if(node_in)
			node_in.disconnect(src)
			del(network_in)

		node_out1 = null
		node_out2 = null
		node_in = null

		..()

	initialize()
		if(node_out1 && node_in) return

		var/node_in_connect = turn(dir, -180)
		var/node_out1_connect = turn(dir, -90)
		var/node_out2_connect = dir


		for(var/obj/machinery/atmospherics/target in get_step(src,node_out1_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_out1 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node_out2_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_out2 = target
				break

		for(var/obj/machinery/atmospherics/target in get_step(src,node_in_connect))
			if(target.initialize_directions & get_dir(target,src))
				node_in = target
				break

		update_icon()

		set_frequency(frequency)

	build_network()
		if(!network_out1 && node_out1)
			network_out1 = new /datum/pipe_network()
			network_out1.normal_members += src
			network_out1.build_network(node_out1, src)

		if(!network_out2 && node_out2)
			network_out2 = new /datum/pipe_network()
			network_out2.normal_members += src
			network_out2.build_network(node_out2, src)

		if(!network_in && node_in)
			network_in = new /datum/pipe_network()
			network_in.normal_members += src
			network_in.build_network(node_in, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node_out1)
			return network_out1

		if(reference==node_out2)
			return network_out2

		if(reference==node_in)
			return network_in

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network_out1 == old_network)
			network_out1 = new_network

		if(network_out2 == old_network)
			network_out2 = new_network

		if(network_in == old_network)
			network_in = new_network

		return 1

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(network_out1 == reference)
			results += air_out1

		if(network_out2 == reference)
			results += air_out2

		if(network_in == reference)
			results += air_in

		return results

	disconnect(obj/machinery/atmospherics/reference)
		if(reference==node_out1)
			del(network_out1)
			node_out1 = null

		else if(reference==node_out2)
			del(network_out2)
			node_out2 = null

		else if(reference==node_in)
			del(network_in)
			node_in = null

		return null


obj/machinery/atmospherics/filter/attack_hand(user as mob) // -- TLE
	var/dat
	if(..())
		return
	if (1 == 1)
/*
		dat += "Autolathe Wires:<BR>"
		var/wire
		for(wire in src.wires)
			dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];act=wire'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];act=pulse'>Pulse</A><BR>")

		dat += text("The red light is [src.disabled ? "off" : "on"].<BR>")
		dat += text("The green light is [src.shocked ? "off" : "on"].<BR>")
		dat += text("The blue light is [src.hacked ? "off" : "on"].<BR>")
*/
		var/current_filter_type
		switch(filter_type)
			if(0)
				current_filter_type = "Carbon Molecules"
			if(1)
				current_filter_type = "Oxygen"
			if(2)
				current_filter_type = "Nitrogen"
			if(3)
				current_filter_type = "Carbon Dioxide"
			else
				current_filter_type = "ERROR - Report this bug to the admin, please!"

		dat += "<b>Filtering: </b>[current_filter_type]<br><br>"
		dat += "<h3>Set Filter Type:</h3><BR>"
		dat += "<A href='?src=\ref[src];filterset=0'>Carbon Molecules</A><BR>"
		dat += "<A href='?src=\ref[src];filterset=1'>Oxygen</A><BR>"
		dat += "<A href='?src=\ref[src];filterset=2'>Nitrogen</A><BR>"
		dat += "<A href='?src=\ref[src];filterset=3'>Carbon Dioxide</A><BR>"

		user << browse("<HEAD><TITLE>Atmospherics Filter</TITLE></HEAD>[dat]","window=atmo_filter")
		onclose(user, "atmo_filter")
		return
	if (src.temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];temp=1'>Clear Screen</A>", src.temp, src)
	//else
	//	src.on != src.on
	user << browse("<HEAD><TITLE>Autolathe Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=atmo_filter")
	onclose(user, "atmo_filter")
	return

obj/machinery/atmospherics/filter/Topic(href, href_list) // -- TLE
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["filterset"])
		if(href_list["filterset"] == "0")
			src.filter_type = 0
		if(href_list["filterset"] == "1")
			src.filter_type = 1
		if(href_list["filterset"] == "2")
			src.filter_type = 2
		if(href_list["filterset"] == "3")
			src.filter_type = 3
	if (href_list["temp"])
		src.temp = null

	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	return