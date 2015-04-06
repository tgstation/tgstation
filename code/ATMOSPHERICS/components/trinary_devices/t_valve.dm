/obj/machinery/atmospherics/trinary/tvalve
	icon = 'icons/obj/atmospherics/valve.dmi'
	icon_state = "tvalve0"

	name = "manual switching valve"
	desc = "A pipe valve"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST

	mirror = /obj/machinery/atmospherics/trinary/tvalve/mirrored

	state = 0 // 0 = go straight, 1 = go to side

/obj/machinery/atmospherics/trinary/tvalve/update_icon(animation)
	if(animation)
		flick("tvalve[src.state][!src.state]",src)
	else
		icon_state = "tvalve[state]"

/obj/machinery/atmospherics/trinary/tvalve/investigation_log(var/subject, var/message)
	activity_log += ..()

/obj/machinery/atmospherics/trinary/tvalve/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network1 = new_network
		if(state)
			network2 = new_network
		else
			network3 = new_network
	else if(reference == node2)
		network2 = new_network
		if(state)
			network1 = new_network
	else if(reference == node3)
		network3 = new_network
		if(!state)
			network1 = new_network

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

/obj/machinery/atmospherics/trinary/tvalve/initialize()
	..()

	//force build the networks.
	go_to_side()
	go_straight()

/obj/machinery/atmospherics/trinary/tvalve/proc/go_to_side()

	if(state) return 0

	state = 1
	update_icon()

	if(network1)
		returnToDPool(network1)
	if(network3)
		returnToDPool(network3)
	build_network()

	if(network1&&network2)
		network1.merge(network2)
		network2 = network1

	if(network1)
		network1.update = 1
	else if(network2)
		network2.update = 1

	return 1

/obj/machinery/atmospherics/trinary/tvalve/proc/go_straight()

	if(!state)
		return 0

	state = 0
	update_icon()

	if(network1)
		returnToDPool(network1)
	if(network2)
		returnToDPool(network2)
	build_network()

	if(network1&&network3)
		network1.merge(network3)
		network3 = network1

	if(network1)
		network1.update = 1
	else if(network3)
		network3.update = 1

	return 1

/obj/machinery/atmospherics/trinary/tvalve/attack_ai(mob/user as mob)
	return

/obj/machinery/atmospherics/trinary/tvalve/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/atmospherics/trinary/tvalve/attack_hand(mob/user as mob)
	if(isobserver(user) && !canGhostWrite(user,src,"toggles"))
		user << "<span class='warning'>Nope.</span>"
		return

	investigation_log(I_ATMOS,"was [state ? "opened (straight)" : "closed (side)"] by [key_name(usr)]")

	src.add_fingerprint(usr)
	update_icon(1)
	sleep(10)
	if (src.state)
		src.go_straight()
	else
		src.go_to_side()

/obj/machinery/atmospherics/trinary/tvalve/process()
	..()
	//machines.Remove(src)

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

/obj/machinery/atmospherics/trinary/tvalve/return_network_air(datum/network/reference)
	return null

/obj/machinery/atmospherics/trinary/tvalve/mirrored
	icon_state = "tvalvem0"
	pipe_flags = IS_MIRROR

/obj/machinery/atmospherics/trinary/tvalve/mirrored/update_icon(animation)
	if(animation)
		flick("tvalvem[src.state][!src.state]",src)
	else
		icon_state = "tvalvem[state]"


////////////////////
////DIGITAL T///////
////////////////////

/obj/machinery/atmospherics/trinary/tvalve/digital		// can be controlled by AI
	name = "digital switching valve"
	desc = "A digitally controlled valve."
	icon = 'icons/obj/atmospherics/digital_valve.dmi'

	var/frequency = 0
	var/id_tag = null
	var/datum/radio_frequency/radio_connection

	mirror = /obj/machinery/atmospherics/trinary/tvalve/digital/mirrored

/obj/machinery/atmospherics/trinary/tvalve/digital/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/trinary/tvalve/digital/attack_hand(mob/user as mob)
	if(!src.allowed(user))
		user << "<span class='warning'>Access denied.</span>"
		return
	..()

		//Radio remote control

/obj/machinery/atmospherics/trinary/tvalve/digital/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/trinary/tvalve/digital/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/trinary/tvalve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	var/state_changed=0
	switch(signal.data["command"])
		if("valve_open")
			if(!state)
				go_to_side()
				state_changed=1

		if("valve_close")
			if(state)
				go_straight()
				state_changed=1

		if("valve_toggle")
			if(state)
				go_straight()
			else
				go_to_side()
			state_changed=1
	if(state_changed)
		investigation_log(I_ATMOS,"was [(state ? "opened (side)" : "closed (straight) ")] by a signal")

/obj/machinery/atmospherics/trinary/tvalve/digital/mirrored
	icon_state = "tvalvem0"
	pipe_flags = IS_MIRROR

/obj/machinery/atmospherics/trinary/tvalve/digital/mirrored/update_icon(animation)
	if(animation)
		flick("tvalvem[src.state][!src.state]",src)
	else
		icon_state = "tvalvem[state]"
