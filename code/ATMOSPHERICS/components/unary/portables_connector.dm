/obj/machinery/atmospherics/unary/portables_connector
	icon = 'icons/obj/atmospherics/portables_connector.dmi'
	icon_state = "hintact"

	name = "Connector Port"
	desc = "For connecting portables devices related to atmospherics control."

	var/obj/machinery/portable_atmospherics/connected_device

	var/on = 0
	use_power = 0
	level = 0


/obj/machinery/atmospherics/unary/portables_connector/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/unary/portables_connector/update_icon()
	..()
	if (istype(loc, /turf/simulated/floor) && node)
		var/turf/simulated/floor/floor = loc
		if(floor.floor_tile && node.alpha == 128)
			underlays.Cut()
	return

/obj/machinery/atmospherics/unary/portables_connector/hide(var/i) //to make the little pipe section invisible, the icon changes.
	update_icon()

/obj/machinery/atmospherics/unary/portables_connector/process()
	. = ..()
	if(!on)
		return
	if(!connected_device)
		on = 0
		return
	if(network)
		network.update = 1
	return 1

/obj/machinery/atmospherics/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()

	if(node)
		node.disconnect(src)
		if(network)
			returnToPool(network)

	node = null

	..()

/obj/machinery/atmospherics/unary/portables_connector/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node)
		return network

	if(reference==connected_device)
		return network

	return null

/obj/machinery/atmospherics/unary/portables_connector/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(connected_device)
		results += connected_device.air_contents

	return results


/obj/machinery/atmospherics/unary/portables_connector/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (connected_device)
		to_chat(user, "<span class='warning'>You cannot unwrench this [src], dettach [connected_device] first.</span>")
		return 1
	if (locate(/obj/machinery/portable_atmospherics, src.loc))
		return 1
	return ..()
