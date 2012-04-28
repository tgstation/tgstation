obj/machinery/atmospherics/tvalve
	icon = 'valve.dmi'
	icon_state = "tvalve0"

	name = "manual switching valve"
	desc = "A pipe valve"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST

	var/state = 0 // 0 = go straight, 1 = go to side

	// like a trinary component, node1 is input, node2 is side output, node3 is straight output
	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2
	var/obj/machinery/atmospherics/node3

	var/datum/pipe_network/network_node1
	var/datum/pipe_network/network_node2
	var/datum/pipe_network/network_node3

	update_icon(animation)
		if(animation)
			flick("tvalve[src.state][!src.state]",src)
		else
			icon_state = "tvalve[state]"

	New()
		switch(dir)
			if(NORTH)
				initialize_directions = SOUTH|NORTH|EAST
			if(SOUTH)
				initialize_directions = NORTH|SOUTH|WEST
			if(EAST)
				initialize_directions = WEST|EAST|SOUTH
			if(WEST)
				initialize_directions = EAST|WEST|NORTH
		..()

	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(reference == node1)
			network_node1 = new_network
			if(state)
				network_node2 = new_network
			else
				network_node3 = new_network
		else if(reference == node2)
			network_node2 = new_network
			if(state)
				network_node1 = new_network
		else if(reference == node3)
			network_node3 = new_network
			if(!state)
				network_node1 = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		if(state)
			if(reference == node1)
				if(node2)
					return node2.network_expand(new_network, src)
			else if(reference == node2)
				if(node1)
					return node1.network_expand(new_network, src)
		else
			if(reference == node1)
				if(node3)
					return node3.network_expand(new_network, src)
			else if(reference == node3)
				if(node1)
					return node1.network_expand(new_network, src)

		return null

	Del()
		loc = null

		if(node1)
			node1.disconnect(src)
			del(network_node1)
		if(node2)
			node2.disconnect(src)
			del(network_node2)
		if(node3)
			node3.disconnect(src)
			del(network_node3)

		node1 = null
		node2 = null
		node3 = null

		..()

	proc/go_to_side()

		if(state) return 0

		state = 1
		update_icon()

		if(network_node1)
			del(network_node1)
		if(network_node3)
			del(network_node3)
		build_network()

		if(network_node1&&network_node2)
			network_node1.merge(network_node2)
			network_node2 = network_node1

		if(network_node1)
			network_node1.update = 1
		else if(network_node2)
			network_node2.update = 1

		return 1

	proc/go_straight()

		if(!state)
			return 0

		state = 0
		update_icon()

		if(network_node1)
			del(network_node1)
		if(network_node2)
			del(network_node2)
		build_network()

		if(network_node1&&network_node3)
			network_node1.merge(network_node3)
			network_node3 = network_node1

		if(network_node1)
			network_node1.update = 1
		else if(network_node3)
			network_node3.update = 1

		return 1

	attack_ai(mob/user as mob)
		return

	attack_paw(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		src.add_fingerprint(usr)
		update_icon(1)
		sleep(10)
		if (src.state)
			src.go_straight()
		else
			src.go_to_side()

	process()
		..()
		machines.Remove(src)

/*		if(open && (!node1 || !node2))
			close()
		if(!node1)
			if(!nodealert)
				//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
				nodealert = 1
		else if (!node2)
			if(!nodealert)
				//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
				nodealert = 1
		else if (nodealert)
			nodealert = 0
*/

		return

	initialize()
		var/node1_dir
		var/node2_dir
		var/node3_dir

		node1_dir = turn(dir, 180)
		node2_dir = turn(dir, -90)
		node3_dir = dir

		for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
			if(target.initialize_directions & get_dir(target,src))
				node1 = target
				break
		for(var/obj/machinery/atmospherics/target in get_step(src,node2_dir))
			if(target.initialize_directions & get_dir(target,src))
				node2 = target
				break
		for(var/obj/machinery/atmospherics/target in get_step(src,node3_dir))
			if(target.initialize_directions & get_dir(target,src))
				node3 = target
				break

	build_network()
		if(!network_node1 && node1)
			network_node1 = new /datum/pipe_network()
			network_node1.normal_members += src
			network_node1.build_network(node1, src)

		if(!network_node2 && node2)
			network_node2 = new /datum/pipe_network()
			network_node2.normal_members += src
			network_node2.build_network(node2, src)

		if(!network_node3 && node3)
			network_node3 = new /datum/pipe_network()
			network_node3.normal_members += src
			network_node3.build_network(node3, src)


	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node1)
			return network_node1

		if(reference==node2)
			return network_node2

		if(reference==node3)
			return network_node3

		return null

	reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
		if(network_node1 == old_network)
			network_node1 = new_network
		if(network_node2 == old_network)
			network_node2 = new_network
		if(network_node3 == old_network)
			network_node3 = new_network

		return 1

	return_network_air(datum/network/reference)
		return null

	disconnect(obj/machinery/atmospherics/reference)
		if(reference==node1)
			del(network_node1)
			node1 = null

		else if(reference==node2)
			del(network_node2)
			node2 = null

		else if(reference==node3)
			del(network_node3)
			node2 = null

		return null

	digital		// can be controlled by AI
		name = "digital switching valve"
		desc = "A digitally controlled valve."
		icon = 'digital_valve.dmi'

		attack_ai(mob/user as mob)
			return src.attack_hand(user)

		attack_hand(mob/user as mob)
			if(!src.allowed(user))
				user << "\red Access denied."
				return
			..()

		//Radio remote control

		proc
			set_frequency(new_frequency)
				radio_controller.remove_object(src, frequency)
				frequency = new_frequency
				if(frequency)
					radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

		var/frequency = 0
		var/id = null
		var/datum/radio_frequency/radio_connection

		initialize()
			..()
			if(frequency)
				set_frequency(frequency)

		receive_signal(datum/signal/signal)
			if(!signal.data["tag"] || (signal.data["tag"] != id))
				return 0

			switch(signal.data["command"])
				if("valve_open")
					if(!state)
						go_to_side()

				if("valve_close")
					if(state)
						go_straight()

				if("valve_toggle")
					if(state)
						go_straight()
					else
						go_to_side()

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		if (istype(src, /obj/machinery/atmospherics/tvalve/digital))
			user << "\red You cannot unwrench this [src], it's too complicated."
			return 1
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			del(src)

obj/machinery/atmospherics/tvalve/mirrored
	icon_state = "tvalvem0"

	initialize()
		var/node1_dir
		var/node2_dir
		var/node3_dir

		node1_dir = turn(dir, 180)
		node2_dir = turn(dir, 90)
		node3_dir = dir

		for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
			if(target.initialize_directions & get_dir(target,src))
				node1 = target
				break
		for(var/obj/machinery/atmospherics/target in get_step(src,node2_dir))
			if(target.initialize_directions & get_dir(target,src))
				node2 = target
				break
		for(var/obj/machinery/atmospherics/target in get_step(src,node3_dir))
			if(target.initialize_directions & get_dir(target,src))
				node3 = target
				break

	update_icon(animation)
		if(animation)
			flick("tvalvem[src.state][!src.state]",src)
		else
			icon_state = "tvalvem[state]"

	digital		// can be controlled by AI
		name = "digital switching valve"
		desc = "A digitally controlled valve."
		icon = 'digital_valve.dmi'

		attack_ai(mob/user as mob)
			return src.attack_hand(user)

		attack_hand(mob/user as mob)
			if(!src.allowed(user))
				user << "\red Access denied."
				return
			..()

		//Radio remote control

		proc
			set_frequency(new_frequency)
				radio_controller.remove_object(src, frequency)
				frequency = new_frequency
				if(frequency)
					radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

		var/frequency = 0
		var/id = null
		var/datum/radio_frequency/radio_connection

		initialize()
			..()
			if(frequency)
				set_frequency(frequency)

		receive_signal(datum/signal/signal)
			if(!signal.data["tag"] || (signal.data["tag"] != id))
				return 0

			switch(signal.data["command"])
				if("valve_open")
					if(!state)
						go_to_side()

				if("valve_close")
					if(state)
						go_straight()

				if("valve_toggle")
					if(state)
						go_straight()
					else
						go_to_side()