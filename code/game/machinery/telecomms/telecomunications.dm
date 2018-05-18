
/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The telecom machines were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

/obj/machinery/telecomms
	icon = 'icons/obj/machines/telecomms.dmi'
	critical_machine = TRUE
	var/traffic = 0 // value increases as traffic increases
	var/netspeed = 5 // how much traffic to lose per tick (50 gigabytes/second * netspeed)
	var/id = "NULL" // identification string
	var/network = "NULL" // the network of the machinery

	var/list/freq_listening = list() // list of frequencies to tune into: if none, will listen to all

	var/on = TRUE
	var/toggled = TRUE 	// Is it toggled on
	var/long_range_link = FALSE  // Can you link it across Z levels or on the otherside of the map? (Relay & Hub)
	var/hide = FALSE  // Is it a hidden machine?

/obj/machinery/telecomms/proc/TCLinks()
	return GetLinkedAtoms(long_range_link ? /obj/machinery/telecomms : GetZLevelLinkGroupId())

/obj/machinery/telecomms/proc/relay_information(datum/signal/subspace/signal, filter, copysig, amount = 20)
	// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending

	if(!on)
		return
	var/send_count = 0

	// Apply some lag based on traffic rates
	var/netlag = round(traffic / 50)
	if(netlag > signal.data["slow"])
		signal.data["slow"] = netlag

	// Loop through all linked machines and send the signal or copy.
	for(var/obj/machinery/telecomms/machine in TCLinks())
		if(machine == src)
			return
		if(filter && !istype( machine, filter ))
			continue
		if(!machine.on)
			continue
		if(amount && send_count >= amount)
			break
		var/turf/their_turf = get_turf(machine)
		if(z != their_turf?.z && !machine.long_range_link)
			continue

		send_count++
		if(machine.is_freq_listening(signal))
			machine.traffic++

		if(copysig)
			machine.receive_information(signal.copy(), src)
		else
			machine.receive_information(signal, src)

	if(send_count > 0 && is_freq_listening(signal))
		traffic++

	return send_count

/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	// send signal directly to a machine
	machine.receive_information(signal, src)

/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	// receive information from linked machinery

/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	// return TRUE if found, FALSE if not found
	return signal && (!freq_listening.len || (signal.frequency in freq_listening))

/obj/machinery/telecomms/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/atom_linker, /obj/machinery/telecomms)
	var/turf/T = get_turf(src)
	if(T)
		JoinZLevelLinkGroup(T.z)
	if(mapload && autolinkers.len)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/telecomms/proc/GetZLevelLinkGroupId(z_level)
	if(!z_level)
		var/turf/T = get_turf(src)
		if(!T)
			return	//this is an error
		z_level = T.z
	return "[/obj/machinery/telecomms][z_level]"

/obj/machinery/telecomms/proc/JoinZLevelLinkGroup(z_level)
	AddComponent(/datum/component/atom_linker, GetZLevelLinkGroupId(z_level))

/obj/machinery/telecomms/onTransitZ(old_z, new_z)
	. = ..()
	var/search = GetZLevelLinkGroupId(old_z)
	for(var/I in GetComponents(/datum/component/atom_linker))
		var/datum/component/atom_linker/al = I
		if(al.id == search)
			qdel(al)
			break
	JoinZLevelLinkGroup(new_z)

/obj/machinery/telecomms/update_icon()
	if(on)
		if(panel_open)
			icon_state = "[initial(icon_state)]_o"
		else
			icon_state = initial(icon_state)
	else
		if(panel_open)
			icon_state = "[initial(icon_state)]_o_off"
		else
			icon_state = "[initial(icon_state)]_off"

/obj/machinery/telecomms/proc/update_power()

	if(toggled)
		if(stat & (BROKEN|NOPOWER|EMPED)) // if powered, on. if not powered, off. if too damaged, off
			on = FALSE
		else
			on = TRUE
	else
		on = FALSE

/obj/machinery/telecomms/process()
	update_power()

	// Update the icon
	update_icon()

	if(traffic > 0)
		traffic -= netspeed

/obj/machinery/telecomms/emp_act(severity)
	if(prob(100/severity))
		if(!(stat & EMPED))
			stat |= EMPED
			var/duration = (300 * 10)/severity
			spawn(rand(duration - 20, duration + 20)) // Takes a long time for the machines to reboot.
				stat &= ~EMPED
	..()
