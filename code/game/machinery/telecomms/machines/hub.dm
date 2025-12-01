/**
 * The HUB idles until it receives information. It then passes on that information
 * depending on where it came from.
 *
 * This is the heart of the Telecommunications Network, sending information where it
 * is needed. It mainly receives information from long-distance Relays and then sends
 * that information to be processed. Afterwards it gets the uncompressed information
 * from Servers/Buses and sends that back to the relay, to then be broadcasted.
 */
/obj/machinery/telecomms/hub
	name = "telecommunication hub"
	icon_state = "hub"
	desc = "A mighty piece of hardware used to send/receive massive amounts of data."
	telecomms_type = /obj/machinery/telecomms/hub
	density = TRUE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	long_range_link = TRUE
	netspeed = 40
	circuit = /obj/item/circuitboard/machine/telecomms/hub

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

	use_energy(idle_power_usage)

/obj/machinery/telecomms/hub/update_power()
	var/old_on = on
	if(toggled)
		if(machine_stat & (BROKEN|NOPOWER|EMPED))
			on = FALSE
			soundloop.stop()
		else
			on = TRUE
			soundloop.start()
	else
		on = FALSE
	if(old_on != on)
		update_appearance()

/obj/machinery/telecomms/hub/Initialize(mapload)
	. = ..()
	soundloop = new(src, on)

/obj/machinery/telecomms/hub/Destroy()
	QDEL_NULL(soundloop)
	return ..()

// Preset HUB

/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list(
		"hub",
		"relay",
		"s_relay",
		"m_relay",
		"r_relay",
		"science",
		"medical",
		"supply",
		"service",
		"common",
		"command",
		"engineering",
		"entertainment",
		"security",
		"receiverA",
		"receiverB",
		"broadcasterA",
		"broadcasterB",
		"autorelay",
		"messaging",
	)

