/// A list of all of the `/obj/machinery/telecomms` (and subtypes) machines
/// that exist in the world currently.
GLOBAL_LIST_EMPTY(telecomms_list)

/**
 * The basic telecomms machinery type, implementing all of the logic that's
 * shared between all of the telecomms machinery.
 */
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

	/// Is it actually active or not?
	var/on = TRUE
	/// Is it toggled on, so is it /meant/ to be active?
	var/toggled = TRUE
	/// Can you link it across Z levels or on the otherside of the map? (Relay & Hub)
	var/long_range_link = FALSE
	/// Is it a hidden machine?
	var/hide = FALSE

	/// Looping sounds for any servers
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

/// Sends a signal directly to a machine.
/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	machine.receive_information(signal, src)

/// Receive information from linked machinery
/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	return

/**
 * Checks whether the machinery is listening to that signal.
 *
 * Returns `TRUE` if found, `FALSE` if not.
 */
/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	return signal && (!length(freq_listening) || (signal.frequency in freq_listening))

/obj/machinery/telecomms/Initialize(mapload)
	. = ..()
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
	for(var/obj/machinery/telecomms/comm in GLOB.telecomms_list)
		remove_link(comm)
	links = list()
	return ..()

/// Handles the automatic linking of another machine to this one.
/obj/machinery/telecomms/proc/add_automatic_link(obj/machinery/telecomms/machine_to_link)
	var/turf/position = get_turf(src)
	var/turf/T_position = get_turf(machine_to_link)
	if((position.z != T_position.z) && !(long_range_link && machine_to_link.long_range_link))
		return
	if(src == machine_to_link)
		return
	for(var/autolinker_id in autolinkers)
		if(autolinker_id in machine_to_link.autolinkers)
			add_new_link(machine_to_link)
			return

/obj/machinery/telecomms/update_icon_state()
	icon_state = "[initial(icon_state)][panel_open ? "_o" : null][on ? null : "_off"]"
	return ..()

/obj/machinery/telecomms/on_set_panel_open(old_value)
	update_appearance()
	return ..()

/**
 * Handles updating the power state of the machine, modifying its `on`
 * variable based on if it's `toggled` and if it's either broken, has no power
 * or it's EMP'd. Handles updating appearance based on that power change.
 */
/obj/machinery/telecomms/proc/update_power()
	var/old_on = on
	if(toggled)
		if(machine_stat & (BROKEN|NOPOWER|EMPED)) // if powered, on. if not powered, off. if too damaged, off
			on = FALSE
		else
			on = TRUE
	else
		on = FALSE
	if(old_on != on)
		update_appearance()

/obj/machinery/telecomms/process(seconds_per_tick)
	update_power()

	if(traffic > 0)
		traffic -= netspeed * seconds_per_tick

/obj/machinery/telecomms/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(100/severity) && !(machine_stat & EMPED))
		set_machine_stat(machine_stat | EMPED)
		var/duration = (300 SECONDS)/severity
		addtimer(CALLBACK(src, PROC_REF(de_emp)), rand(duration - 2 SECONDS, duration + 2 SECONDS))

/// Handles the machine stopping being affected by an EMP.
/obj/machinery/telecomms/proc/de_emp()
	set_machine_stat(machine_stat & ~EMPED)
