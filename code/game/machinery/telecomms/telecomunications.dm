
/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The telecom machines were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

var/global/list/obj/machinery/telecomms/telecomms_list = list()

/obj/machinery/telecomms
	icon = 'icons/obj/machines/telecomms.dmi'
	var/list/links = list() // list of machines this machine is linked to
	var/traffic = 0 // value increases as traffic increases
	var/netspeed = 5 // how much traffic to lose per tick (50 gigabytes/second * netspeed)
	var/list/autolinkers = list() // list of text/number values to link with
	var/id = "NULL" // identification string
	var/network = "NULL" // the network of the machinery

	var/list/freq_listening = list() // list of frequencies to tune into: if none, will listen to all

	var/machinetype = 0 // just a hacky way of preventing alike machines from pairing
	var/toggled = 1 	// Is it toggled on
	var/on = 1
	var/long_range_link = 0	// Can you link it across Z levels or on the otherside of the map? (Relay & Hub)
	var/hide = 0				// Is it a hidden machine?
	var/listening_level = 0	// 0 = auto set in New() - this is the z level that the machine is listening to.
	critical_machine = TRUE


/obj/machinery/telecomms/proc/relay_information(datum/signal/signal, filter, copysig, amount = 20)
	// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending

	if(!on)
		return
	var/send_count = 0

	// Apply some lag based on traffic rates
	var/netlag = round(traffic / 50)
	if(netlag > signal.data["slow"])
		signal.data["slow"] = netlag

// Loop through all linked machines and send the signal or copy.
	for(var/obj/machinery/telecomms/machine in links)
		if(filter && !istype( machine, text2path(filter) ))
			continue
		if(!machine.on)
			continue
		if(amount && send_count >= amount)
			break
		if(machine.loc.z != listening_level)
			if(long_range_link == 0 && machine.long_range_link == 0)
				continue
		// If we're sending a copy, be sure to create the copy for EACH machine and paste the data
		var/datum/signal/copy = new
		if(copysig)

			copy.transmission_method = 2
			copy.frequency = signal.frequency
			// Copy the main data contents! Workaround for some nasty bug where the actual array memory is copied and not its contents.
			copy.data = list(

			"mob" = signal.data["mob"],
			"mobtype" = signal.data["mobtype"],
			"realname" = signal.data["realname"],
			"name" = signal.data["name"],
			"job" = signal.data["job"],
			"key" = signal.data["key"],
			"vmask" = signal.data["vmask"],
			"compression" = signal.data["compression"],
			"message" = signal.data["message"],
			"radio" = signal.data["radio"],
			"slow" = signal.data["slow"],
			"traffic" = signal.data["traffic"],
			"type" = signal.data["type"],
			"server" = signal.data["server"],
			"reject" = signal.data["reject"],
			"level" = signal.data["level"],
			"spans" = signal.data["spans"],
			"verb_say" = signal.data["verb_say"],
			"verb_ask" = signal.data["verb_ask"],
			"verb_exclaim" = signal.data["verb_exclaim"],
			"verb_yell" = signal.data["verb_yell"]
			)

			// Keep the "original" signal constant
			if(!signal.data["original"])
				copy.data["original"] = signal
			else
				copy.data["original"] = signal.data["original"]

		else
			copy = null


		send_count++
		if(machine.is_freq_listening(signal))
			machine.traffic++

		if(copysig && copy)
			machine.receive_information(copy, src)
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
	..()

/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	// return 1 if found, 0 if not found
	if(!signal)
		return 0
	if((signal.frequency in freq_listening) || (!freq_listening.len))
		return 1
	else
		return 0


/obj/machinery/telecomms/New()
	telecomms_list += src
	..()

	//Set the listening_level if there's none.
	if(!listening_level)
		//Defaults to our Z level!
		var/turf/position = get_turf(src)
		listening_level = position.z

/obj/machinery/telecomms/onShuttleMove(turf/T1, rotation)
	. = ..()
	if(. && T1) // Update listening Z, just in case you have telecomm relay on a shuttle
		listening_level = T1.z

/obj/machinery/telecomms/Initialize(mapload)
	..()
	if(mapload && autolinkers.len)
		// Links nearby machines
		if(!long_range_link)
			for(var/obj/machinery/telecomms/T in urange(20, src, 1))
				add_link(T)
		else
			for(var/obj/machinery/telecomms/T in telecomms_list)
				add_link(T)


/obj/machinery/telecomms/Destroy()
	telecomms_list -= src
	for(var/obj/machinery/telecomms/comm in telecomms_list)
		comm.links -= src
	links = list()
	return ..()

// Used in auto linking
/obj/machinery/telecomms/proc/add_link(obj/machinery/telecomms/T)
	var/turf/position = get_turf(src)
	var/turf/T_position = get_turf(T)
	if((position.z == T_position.z) || (src.long_range_link && T.long_range_link))
		if(src != T)
			for(var/x in autolinkers)
				if(x in T.autolinkers)
					links |= T
					break

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
			on = 0
		else
			on = 1
	else
		on = 0

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
