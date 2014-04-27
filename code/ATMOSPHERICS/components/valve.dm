
/*
This file contains:
Manual Valve
Digital Valve

These pipes are not under the binary_atmos base because instead of doing pretty maths, they simply
connect the networks together for a more efficient transfer
*/

/obj/machinery/atmospherics/valve
	icon = 'icons/obj/atmospherics/binary_devices.dmi'
	icon_state = "mvalve_off"

	name = "manual valve"
	desc = "A valve which can only be cranked by the strength of mortal hands."

	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	can_unwrench = 1

	var/open = 0
	var/openDuringInit = 0

	var/obj/machinery/atmospherics/node1
	var/obj/machinery/atmospherics/node2

	var/datum/pipe_network/network_node1
	var/datum/pipe_network/network_node2

/obj/machinery/atmospherics/valve/open
	open = 1

//Separate this because we don't need to update pipe icons if we just are going to crank the handle
/obj/machinery/atmospherics/valve/proc/update_icon_nopipes(var/animation)
	normalize_dir()
	icon_state = "mvalve_off"

	overlays.Cut()
	if(animation)
		overlays += image('icons/obj/atmospherics/binary_devices.dmi', icon_state = "mvalve_[open][!open]")
	else if(open)
		overlays += image('icons/obj/atmospherics/binary_devices.dmi', icon_state = "mvalve_on")

/obj/machinery/atmospherics/valve/update_icon(var/animation)
	update_icon_nopipes(animation)

	var/image/img
	var/connected = 0
	underlays.Cut()

	//Add non-broken pieces
	if(node1)
		img = image('icons/obj/atmospherics/binary_devices.dmi', icon_state="pipe_intact", dir=get_dir(src,node1))
		img.color = node1.pipe_color
		underlays += img

		connected |= img.dir

	if(node2)
		img = image('icons/obj/atmospherics/binary_devices.dmi', icon_state="pipe_intact", dir=get_dir(src,node2))
		img.color = node2.pipe_color
		underlays += img

		connected |= img.dir

	//Add broken pieces
	var/unconnected = (~connected) & initialize_directions
	for(var/direction in cardinal)
		if(unconnected & direction)
			img = image('icons/obj/atmospherics/binary_devices.dmi', icon_state="pipe_exposed", dir=direction)
			underlays += img

/obj/machinery/atmospherics/valve/New()
	..()
	switch(dir)
		if(NORTH || SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/valve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network_node1 = new_network
		if(open)
			network_node2 = new_network
	else if(reference == node2)
		network_node2 = new_network
		if(open)
			network_node1 = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	if(open)
		if(reference == node1)
			if(node2)
				return node2.network_expand(new_network, src)
		else if(reference == node2)
			if(node1)
				return node1.network_expand(new_network, src)

	return null

/obj/machinery/atmospherics/valve/Destroy()
	if(node1)
		node1.disconnect(src)
		del(network_node1)
	if(node2)
		node2.disconnect(src)
		del(network_node2)

	node1 = null
	node2 = null

	..()

/obj/machinery/atmospherics/valve/proc/open()
	if(open)
		return 0

	open = 1
	update_icon_nopipes()

	if(network_node1&&network_node2)
		network_node1.merge(network_node2)
		network_node2 = network_node1

	if(network_node1)
		network_node1.update = 1
	else if(network_node2)
		network_node2.update = 1

	return 1

/obj/machinery/atmospherics/valve/proc/close()
	if(!open)
		return 0

	open = 0
	update_icon_nopipes()

	if(network_node1)
		del(network_node1)
	if(network_node2)
		del(network_node2)

	build_network()

	return 1

/obj/machinery/atmospherics/valve/proc/normalize_dir()
	if(dir==NORTH)
		dir = SOUTH
	else if(dir==WEST)
		dir = EAST
	else if(dir==3)
		dir = SOUTH
	else if(dir==12)
		dir = EAST

/obj/machinery/atmospherics/valve/attack_ai(mob/user as mob)
	return

/obj/machinery/atmospherics/valve/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/atmospherics/valve/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)

	update_icon_nopipes(1)

	sleep(10)

	if (open)
		close()
	else
		open()

/obj/machinery/atmospherics/valve/process()
	..()
	. = PROCESS_KILL

	return

/obj/machinery/atmospherics/valve/initialize()
	normalize_dir()

	var/node1_dir
	var/node2_dir

	for(var/direction in cardinal)
		if(direction&initialize_directions)
			if (!node1_dir)
				node1_dir = direction
			else if (!node2_dir)
				node2_dir = direction

	for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
		if(target.initialize_directions & get_dir(target,src))
			node1 = target
			break
	for(var/obj/machinery/atmospherics/target in get_step(src,node2_dir))
		if(target.initialize_directions & get_dir(target,src))
			node2 = target
			break

	build_network()

	if(openDuringInit)
		close()
		open()
		openDuringInit = 0

	update_icon()

/obj/machinery/atmospherics/valve/build_network()
	if(!network_node1 && node1)
		network_node1 = new /datum/pipe_network()
		network_node1.normal_members += src
		network_node1.build_network(node1, src)

	if(!network_node2 && node2)
		network_node2 = new /datum/pipe_network()
		network_node2.normal_members += src
		network_node2.build_network(node2, src)


/obj/machinery/atmospherics/valve/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node1)
		return network_node1

	if(reference==node2)
		return network_node2

	return null

/obj/machinery/atmospherics/valve/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network_node1 == old_network)
		network_node1 = new_network
	if(network_node2 == old_network)
		network_node2 = new_network

	return 1

/obj/machinery/atmospherics/valve/return_network_air(datum/network/reference)
	return

/obj/machinery/atmospherics/valve/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node1)
		del(network_node1)
		node1 = null

	else if(reference==node2)
		del(network_node2)
		node2 = null

	update_icon()

	return

//
//Digital Valve, exactly the same like Manual except AI can manipulate it.
//
/obj/machinery/atmospherics/valve/digital
	name = "digital valve"
	desc = "A digitally controlled valve. Has a button for use with human fingers."
	icon_state = "dvalve_on"

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/machinery/atmospherics/valve/digital/New()
	..()
	power_change()

/obj/machinery/atmospherics/valve/digital/initialize()
	..()
	power_change()

/obj/machinery/atmospherics/valve/digital/power_change()
	..()
	update_icon_nopipes()

/obj/machinery/atmospherics/valve/digital/update_icon_nopipes(var/animation)
	normalize_dir()

	if(stat & NOPOWER)
		icon_state = "dvalve_nopower"
		overlays.Cut()
		return

	icon_state = "dvalve_off"

	overlays.Cut()
	if(animation)
		overlays += image('icons/obj/atmospherics/binary_devices.dmi', icon_state = "dvalve_[open][!open]")
	else if(open)
		overlays += image('icons/obj/atmospherics/binary_devices.dmi', icon_state = "dvalve_on")

/obj/machinery/atmospherics/valve/digital/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/atmospherics/valve/digital/attack_hand(mob/user as mob)
	if(stat & NOPOWER)
		user << "<span class='notice'>It appears to be powered down.</span>"
		return

	if(!src.allowed(user))
		user << "<span class='warning'>Access denied.</span>"
		return

	..()

//Radio remote control

/obj/machinery/atmospherics/valve/digital/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/valve/digital/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/valve/digital/receive_signal(datum/signal/signal)
	if(stat & NOPOWER)
		return 0

	if(!signal.data["tag"] || (signal.data["tag"] != id))
		return 0

	switch(signal.data["command"])
		if("valve_open")
			if(!open)
				open()

		if("valve_close")
			if(open)
				close()

		if("valve_toggle")
			if(open)
				close()
			else
				open()
