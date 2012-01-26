/obj/machinery/water/glass_connector
	icon = 'water_glass_connector.dmi'
	icon_state = "intact"
	name = "Beaker Connection"
	desc = "For connecting portables devices related to reagents."

	dir = SOUTH
	initialize_directions = SOUTH
	density = 1

	var/icon_type = ""

	var/obj/item/weapon/reagent_containers/glass/connected_device
	var/obj/machinery/water/node
	var/datum/water/pipe_network/network

	New()
		initialize_directions = dir
		..()

	update_icon()
		if(node)
			icon_state = "[node.level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact[icon_type]"
			dir = get_dir(src, node)
		else
			icon_state = "exposed[icon_type]"

		overlays = new()
		if(connected_device)
			overlays += "inserted"

			if(connected_device.reagents.total_volume)
				var/obj/effect/overlay = new/obj
				overlay.icon = 'water_glass_connector.dmi'
				overlay.icon_state = "window"

				var/list/rgbcolor = list(0,0,0)
				var/finalcolor
				for(var/datum/reagent/re in connected_device.reagents.reagent_list) // natural color mixing bullshit/algorithm
					if(!finalcolor)
						rgbcolor = GetColors(re.color)
						finalcolor = re.color
					else
						var/newcolor[3]
						var/prergbcolor[3]
						prergbcolor = rgbcolor
						newcolor = GetColors(re.color)

						rgbcolor[1] = (prergbcolor[1]+newcolor[1])/2
						rgbcolor[2] = (prergbcolor[2]+newcolor[2])/2
						rgbcolor[3] = (prergbcolor[3]+newcolor[3])/2

						finalcolor = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3])
						// This isn't a perfect color mixing system, the more reagents that are inside,
						// the darker it gets until it becomes absolutely pitch black! I dunno, maybe
						// that's pretty realistic? I don't do a whole lot of color-mixing anyway.
						// If you add brighter colors to it it'll eventually get lighter, though.

				overlay.icon += finalcolor
				overlays += overlay

	on_reagent_change(var/mob/user)
		update_icon()

	process()
		..()
		if(!connected_device)
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
			connected_device.loc = src.loc

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

	proc/update_connection(inserting)
		if(inserting)
			if(network && !network.reagents.Find(connected_device.reagents))
				network.reagents += connected_device.reagents
				connected_device.reagents.my_atom = src
				network.update = 1
		else
			if(network && network.reagents.Find(connected_device.reagents))
				network.reagents -= connected_device.reagents
				connected_device.reagents.my_atom = connected_device

	attack_hand(mob/user as mob)
		if (connected_device)
			var/obj/item/weapon/reagent_containers/glass/B = connected_device
			B.loc = src.loc
			update_connection(0)
			connected_device = null
			update_icon()
		else
			..()

	proc/return_pressure()
		return network.return_pressure_transient()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench))
			if(connected_device)
				user << "\red You cannot unwrench this [src], remove [connected_device] first."
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
		else if(istype(W, /obj/item/weapon/reagent_containers/glass))
			if(connected_device)
				user << "\red You cannot insert this [src], remove [connected_device] first."
				return 1
			connected_device = W
			update_connection(1)
			user.drop_item()
			W.loc = src
			update_icon()
			user << "\blue You add \the [W] to \the [src]."
		else
			return ..()

/obj/machinery/water/glass_connector/wall
	icon_state = "intact-w"
	icon_type = "-w"
	density = 0