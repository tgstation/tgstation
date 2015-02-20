/obj/machinery/atmospherics/unary/portables_connector
	icon = 'icons/obj/atmospherics/portables_connector.dmi'
	icon_state = "intact"

	name = "Connector Port"
	desc = "For connecting portables devices related to atmospherics control."

	var/obj/machinery/portable_atmospherics/connected_device

	var/on = 0
	use_power = 0
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

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(node)
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
			dir = get_dir(src, node)
		else
			icon_state = "exposed"

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

	Destroy()
		if(connected_device)
			connected_device.disconnect()

		if(node)
			node.disconnect(src)
			del(network)

		node = null

		..()

	return_network(obj/machinery/atmospherics/reference)
		build_network()

		if(reference==node)
			return network

		if(reference==connected_device)
			return network

		return null

	return_network_air(datum/pipe_network/reference)
		var/list/results = list()

		if(connected_device)
			results += connected_device.air_contents

		return results


	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		if (connected_device)
			user << "\red You cannot unwrench this [src], dettach [connected_device] first."
			return 1
		if (locate(/obj/machinery/portable_atmospherics, src.loc))
			return 1
		return ..()
