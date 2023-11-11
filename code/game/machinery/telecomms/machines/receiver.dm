/**
 * The receiver idles and receives messages from subspace-compatible radio equipment,
 * primarily headsets. Then they just relay this information to all linked devices,
 * which would usually be through the telecommunications hub.
 *
 * Link to Processor Units in case receiver can't send to a telecommunication hub.
 */
/obj/machinery/telecomms/receiver
	name = "subspace receiver"
	icon_state = "broadcast receiver"
	desc = "This machine has a dish-like shape and green lights. It is designed to detect and process subspace radio activity."
	telecomms_type = /obj/machinery/telecomms/receiver
	density = TRUE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	circuit = /obj/item/circuitboard/machine/telecomms/receiver

/obj/machinery/telecomms/receiver/receive_signal(datum/signal/subspace/signal)
	if(!on || !istype(signal) || !check_receive_level(signal) || signal.transmission_method != TRANSMISSION_SUBSPACE)
		return
	if(!is_freq_listening(signal))
		return

	// send the signal to the hub if possible, or a bus otherwise
	if(!relay_information(signal, /obj/machinery/telecomms/hub))
		relay_information(signal, /obj/machinery/telecomms/bus)

	use_power(idle_power_usage)

/**
 * Checks whether the signal can be received by this receiver or not, based on
 * if it's in the signal's `levels`, or if there's a liked hub with a linked
 * relay that can receive the signal for it.
 *
 * Returns `TRUE` if it can receive the signal, `FALSE` if not.
 */
/obj/machinery/telecomms/receiver/proc/check_receive_level(datum/signal/subspace/signal)
	if (z in signal.levels)
		return TRUE

	for(var/obj/machinery/telecomms/hub/linked_hub in links)
		for(var/obj/machinery/telecomms/relay/linked_relay in linked_hub.links)
			if(linked_relay.can_receive(signal) && (linked_relay.z in signal.levels))
				return TRUE

	return FALSE

// Preset Receivers

//--PRESET LEFT--//
/obj/machinery/telecomms/receiver/preset_left
	id = "Receiver A"
	network = "tcommsat"
	autolinkers = list("receiverA") // link to relay
	freq_listening = list(FREQ_SCIENCE, FREQ_MEDICAL, FREQ_SUPPLY, FREQ_SERVICE)


//--PRESET RIGHT--//
/obj/machinery/telecomms/receiver/preset_right
	id = "Receiver B"
	network = "tcommsat"
	autolinkers = list("receiverB") // link to relay
	freq_listening = list(FREQ_COMMAND, FREQ_ENGINEERING, FREQ_SECURITY)

/obj/machinery/telecomms/receiver/preset_right/Initialize(mapload)
	. = ..()
	// Also add common and other freely-available radio frequencies for people
	// to have access to.
	for(var/i = MIN_FREQ, i <= MAX_FREQ, i += 2)
		freq_listening |= i

/obj/machinery/telecomms/receiver/preset_left/birdstation
	name = "Receiver"
	freq_listening = list()
