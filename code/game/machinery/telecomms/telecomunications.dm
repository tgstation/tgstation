
/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The telecom machines were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

GLOBAL_LIST_EMPTY(telecomms_list)

/obj/machinery/telecomms
	icon = 'icons/obj/machines/telecomms.dmi'
	critical_machine = TRUE
	/// list of machines this machine is linked to
	var/list/links = list()
	/**
	 * associative lazylist list of the telecomms_type of linked telecomms machines and a list of said machines.
	 * eg list(telecomms_type1 = list(everything linked to us with that type), telecomms_type2 = list(everything linked to us with THAT type)...)
	 */
	var/list/links_by_telecomms_type
	/// value increases as traffic increases
	var/traffic = 0
	/// how much traffic to lose per second (50 gigabytes/second * netspeed)
	var/netspeed = 2.5
	/// list of text/number values to link with
	var/list/autolinkers = list()
	/// identification string
	var/id = "NULL"
	/// the relevant type path of this telecomms machine eg /obj/machinery/telecomms/server but not server/preset. used for links_by_telecomms_type
	var/telecomms_type = null
	/// the network of the machinery
	var/network = "NULL"

	// list of frequencies to tune into: if none, will listen to all
	var/list/freq_listening = list()

	var/on = TRUE
	/// Is it toggled on
	var/toggled = TRUE
	/// Can you link it across Z levels or on the otherside of the map? (Relay & Hub)
	var/long_range_link = FALSE
	/// Is it a hidden machine?
	var/hide = FALSE

	///Looping sounds for any servers
	var/datum/looping_sound/server/soundloop

/// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending
/obj/machinery/telecomms/proc/relay_information(datum/signal/subspace/signal, filter, copysig, amount = 20)
	if(!on)
		return

	if(!filter || !ispath(filter, /obj/machinery/telecomms))
		CRASH("null or non /obj/machinery/telecomms typepath given as the filter argument! given typepath: [filter]")

	var/send_count = 0

	// Apply some lag based on traffic rates
	var/netlag = round(traffic / 50)
	if(netlag > signal.data["slow"])
		signal.data["slow"] = netlag

	// Loop through all linked machines and send the signal or copy.

	for(var/obj/machinery/telecomms/filtered_machine in links_by_telecomms_type?[filter])
		if(!filtered_machine.on)
			continue
		if(amount && send_count >= amount)
			break
		if(z != filtered_machine.loc.z && !long_range_link && !filtered_machine.long_range_link)
			continue

		send_count++
		if(filtered_machine.is_freq_listening(signal))
			filtered_machine.traffic++

		if(copysig)
			filtered_machine.receive_information(signal.copy(), src)
		else
			filtered_machine.receive_information(signal, src)

	if(send_count > 0 && is_freq_listening(signal))
		traffic++

	return send_count

/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	// send signal directly to a machine
	machine.receive_information(signal, src)

///receive information from linked machinery
/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	return

/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	// return TRUE if found, FALSE if not found
	return signal && (!length(freq_listening) || (signal.frequency in freq_listening))

/obj/machinery/telecomms/Initialize(mapload)
	. = ..()
	soundloop = new(src, on)
	GLOB.telecomms_list += src
	if(mapload && autolinkers.len)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/telecomms/LateInitialize()
	..()

	for(var/obj/machinery/telecomms/telecomms_machine in GLOB.telecomms_list)
		if (long_range_link || IN_GIVEN_RANGE(src, telecomms_machine, 20))
			add_automatic_link(telecomms_machine)

/obj/machinery/telecomms/Destroy()
	GLOB.telecomms_list -= src
	QDEL_NULL(soundloop)
	for(var/obj/machinery/telecomms/comm in GLOB.telecomms_list)
		remove_link(comm)
	links = list()
	return ..()

/// Used in auto linking
/obj/machinery/telecomms/proc/add_automatic_link(obj/machinery/telecomms/T)
	var/turf/position = get_turf(src)
	var/turf/T_position = get_turf(T)
	if((position.z != T_position.z) && !(long_range_link && T.long_range_link))
		return
	if(src == T)
		return
	for(var/autolinker_id in autolinkers)
		if(autolinker_id in T.autolinkers)
			add_new_link(T)
			return

/obj/machinery/telecomms/update_icon_state()
	icon_state = "[initial(icon_state)][panel_open ? "_o" : null][on ? null : "_off"]"
	return ..()

/obj/machinery/telecomms/on_set_panel_open(old_value)
	update_appearance()
	return ..()

/obj/machinery/telecomms/proc/update_power()
	var/old_on = on
	if(toggled)
		if(machine_stat & (BROKEN|NOPOWER|EMPED)) // if powered, on. if not powered, off. if too damaged, off
			on = FALSE
			soundloop.stop()
		else
			on = TRUE
			soundloop.start()
	else
		on = FALSE
		soundloop.stop()
	if(old_on != on)
		update_appearance()

/obj/machinery/telecomms/process(delta_time)
	update_power()

	if(traffic > 0)
		traffic -= netspeed * delta_time

/obj/machinery/telecomms/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(100/severity) && !(machine_stat & EMPED))
		set_machine_stat(machine_stat | EMPED)
		var/duration = (300 * 10)/severity
		addtimer(CALLBACK(src, PROC_REF(de_emp)), rand(duration - 20, duration + 20))

/obj/machinery/telecomms/proc/de_emp()
	set_machine_stat(machine_stat & ~EMPED)
