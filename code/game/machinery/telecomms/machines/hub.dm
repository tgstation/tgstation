/*
	The HUB idles until it receives information. It then passes on that information
	depending on where it came from.

	This is the heart of the Telecommunications Network, sending information where it
	is needed. It mainly receives information from long-distance Relays and then sends
	that information to be processed. Afterwards it gets the uncompressed information
	from Servers/Buses and sends that back to the relay, to then be broadcasted.
*/

/obj/machinery/telecomms/hub
	name = "telecommunication hub"
	icon_state = "hub"
	desc = "A mighty piece of hardware used to send/receive massive amounts of data."
	telecomms_type = /obj/machinery/telecomms/hub
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 80
	long_range_link = TRUE
	netspeed = 40
	circuit = /obj/item/circuitboard/machine/telecomms/hub

	///The looping telecomms sound
	var/datum/looping_sound/server/soundloop

/obj/machinery/telecomms/hub/Initialize(mapload)
	. = ..()
	soundloop = new(src, on)

/obj/machinery/telecomms/hub/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/telecomms/hub/update_power()
	. = ..()
	if(!toggled)
		soundloop.stop()
		return
	if(machine_stat & (BROKEN|NOPOWER|EMPED)) // if powered, on. if not powered, off. if too damaged, off
		soundloop.stop()
	else
		soundloop.start()

/obj/machinery/telecomms/hub/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	if(!is_freq_listening(signal))
		return

	if(istype(machine_from, /obj/machinery/telecomms/receiver))
		// It's probably compressed so send it to the bus.
		relay_information(signal, /obj/machinery/telecomms/bus, TRUE)
	else
		// Send it to each relay so their levels get added...
		relay_information(signal, /obj/machinery/telecomms/relay)
		// Then broadcast that signal to
		relay_information(signal, /obj/machinery/telecomms/broadcaster)

//Preset HUB
/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list(
		"hub", "relay", "s_relay", "m_relay", "r_relay", "h_relay", "science", "medical",
		"supply", "service", "common", "command", "engineering", "security",
		"receiverA", "receiverB", "broadcasterA", "broadcasterB", "autorelay", "messaging",
	)

