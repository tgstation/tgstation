/**
 * The bus mainframe idles and waits for hubs to relay them signals. They act
 * as junctions for the network.
 *
 * They transfer uncompressed subspace packets to processor units, and then take
 * the processed packet to a server for logging.
 *
 * Can be linked to a telecommunications hub or a broadcaster in the absence
 * of a server, at the cost of some added latency.
 */
/obj/machinery/telecomms/bus
	name = "bus mainframe"
	icon_state = "bus"
	desc = "A mighty piece of hardware used to send massive amounts of data quickly."
	telecomms_type = /obj/machinery/telecomms/bus
	density = TRUE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	netspeed = 40
	circuit = /obj/item/circuitboard/machine/telecomms/bus
	/// The frequency this bus will use to override the received signal's frequency,
	/// if not `NONE`.
	var/change_frequency = NONE

/obj/machinery/telecomms/bus/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	if(!istype(signal) || !is_freq_listening(signal))
		return

	if(change_frequency && !(signal.frequency in banned_frequencies))
		signal.frequency = change_frequency

	if(!istype(machine_from, /obj/machinery/telecomms/processor) && machine_from != src) // Signal must be ready (stupid assuming machine), let's send it
		// send to one linked processor unit
		if(relay_information(signal, /obj/machinery/telecomms/processor))
			return

		// failed to send to a processor, relay information anyway
		signal.data["slow"] += rand(1, 5) // slow the signal down only slightly

	// Try sending it!
	var/list/try_send = list(signal.server_type, /obj/machinery/telecomms/hub, /obj/machinery/telecomms/broadcaster)

	var/i = 0
	for(var/send in try_send)
		if(i)
			signal.data["slow"] += rand(0, 1) // slow the signal down only slightly
		i++
		if(relay_information(signal, send))
			break

	use_energy(idle_power_usage)

// Preset Buses

/obj/machinery/telecomms/bus/preset_one
	id = "Bus 1"
	network = "tcommsat"
	freq_listening = list(FREQ_SCIENCE, FREQ_MEDICAL)
	autolinkers = list("processor1", "science", "medical")

/obj/machinery/telecomms/bus/preset_two
	id = "Bus 2"
	network = "tcommsat"
	freq_listening = list(FREQ_SUPPLY, FREQ_SERVICE, FREQ_ENTERTAINMENT)
	autolinkers = list("processor2", "supply", "service", "entertainment")

/obj/machinery/telecomms/bus/preset_three
	id = "Bus 3"
	network = "tcommsat"
	freq_listening = list(FREQ_SECURITY, FREQ_COMMAND)
	autolinkers = list("processor3", "security", "command")

/obj/machinery/telecomms/bus/preset_four
	id = "Bus 4"
	network = "tcommsat"
	freq_listening = list(FREQ_ENGINEERING)
	autolinkers = list("processor4", "engineering", "common", "messaging")

/obj/machinery/telecomms/bus/preset_four/Initialize(mapload)
	. = ..()
	// We want to include every freely-available frequency on this one, so they
	// get processed quickly when used on-station.
	for(var/i = MIN_FREQ, i <= MAX_FREQ, i += 2)
		freq_listening |= i

/obj/machinery/telecomms/bus/preset_one/birdstation
	name = "Bus"
	autolinkers = list("processor1", "common", "messaging")
	freq_listening = list()
