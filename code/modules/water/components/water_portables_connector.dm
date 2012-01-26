/obj/machinery/water/portables_connector
	icon = 'portables_connector.dmi'
	icon_state = "intact"

	name = "Water Connector Port"
	desc = "For connecting reagent dispensers, such as water tanks."

	dir = SOUTH
	initialize_directions = SOUTH

	var/obj/structure/reagent_dispensers/connected_device

	var/obj/machinery/water/node

	var/datum/water/pipe_network/network

	var/on = 0

	level = 0


	New()
		initialize_directions = dir
		..()

	update_icon()
		if(node)
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
			dir = get_dir(src, node)
		else
			icon_state = "exposed"

		return

	process()
		..()
		if(!on)
			return
		if(!connected_device)
			on = 0
			return
		if(network)
			network.update = 1
		return 1

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

		if(connected_device)
			connected_device.disconnect()

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

		if(reference==connected_device)
			return network

		return null

	reassign_network(datum/water/pipe_network/old_network, datum/water/pipe_network/new_network)
		if(network == old_network)
			network = new_network

		return 1

	return_network_reagents(datum/water/pipe_network/reference)
		var/list/results = list()

		if(connected_device)
			results += connected_device.reagents

		return results

	disconnect(obj/machinery/water/reference)
		if(reference==node)
			del(network)
			node = null

		return null

	proc/return_pressure()
		return network.return_pressure_transient()

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		if (connected_device)
			user << "\red You cannot unwrench this [src], dettach [connected_device] first."
			return 1
		if (locate(/obj/structure/reagent_dispensers, src.loc))
			return 1
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
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
			new /obj/item/water_pipe(loc, make_from=src)
			del(src)
