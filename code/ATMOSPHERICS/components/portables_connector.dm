/*
This should ideally have /unary/ as parent, why doesn't it? //Donkie
*/
/obj/machinery/atmospherics/portables_connector
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	icon_state = "connector_map" //Only for mapping purposes, so mappers can see direction

	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."

	dir = SOUTH
	initialize_directions = SOUTH

	can_unwrench = 1

	var/obj/machinery/portable_atmospherics/connected_device

	var/obj/machinery/atmospherics/node

	var/datum/pipe_network/network

	var/showpipe = 0
	var/on = 0
	use_power = 0
	level = 0


/obj/machinery/atmospherics/portables_connector/visible
	level = 2

/obj/machinery/atmospherics/portables_connector/New()
	initialize_directions = dir
	..()

/obj/machinery/atmospherics/portables_connector/update_icon()
	icon_state = "connector"

	underlays.Cut()

	if(showpipe)
		var/state
		var/col
		if(node)
			state = "pipe_intact"
			col = node.pipe_color
		else
			state = "pipe_exposed"

		underlays += getpipeimage('icons/obj/atmospherics/binary_devices.dmi', state, initialize_directions, col)

	return

/obj/machinery/atmospherics/portables_connector/hide(var/intact)
	showpipe = !intact
	update_icon()

	..(intact)

/obj/machinery/atmospherics/portables_connector/process()
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
/obj/machinery/atmospherics/portables_connector/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node)
		network = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	return null

/obj/machinery/atmospherics/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()

	if(node)
		node.disconnect(src)
		del(network)

	node = null

	..()

/obj/machinery/atmospherics/portables_connector/initialize()
	src.disconnect(src)

	var/node_connect = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break
	//build_network() //might need this

	if(level == 2)
		showpipe = 1

	update_icon()

/obj/machinery/atmospherics/portables_connector/build_network()
	if(!network && node)
		network = new /datum/pipe_network()
		network.normal_members += src
		network.build_network(node, src)


/obj/machinery/atmospherics/portables_connector/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node)
		return network

	if(reference==connected_device)
		return network

	return null

/obj/machinery/atmospherics/portables_connector/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network == old_network)
		network = new_network

	return 1

/obj/machinery/atmospherics/portables_connector/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(connected_device)
		results += connected_device.air_contents

	return results

/obj/machinery/atmospherics/portables_connector/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node)
		del(network)
		node = null

	update_icon()

	return null


/obj/machinery/atmospherics/portables_connector/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (connected_device)
		user << "<span class='danger'>You cannot unwrench this [src], detach [connected_device] first.</span>"
		return 1
	return ..()
