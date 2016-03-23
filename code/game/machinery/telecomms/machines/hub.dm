
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
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 80
	machinetype = 7
	//heatgen = 40
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/hub"
	long_range_link = 1
	netspeed = 40


/obj/machinery/telecomms/hub/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	if(is_freq_listening(signal))
		if(istype(machine_from, /obj/machinery/telecomms/receiver))
			//If the signal is compressed, send it to the bus.
			relay_information(signal, "/obj/machinery/telecomms/bus", 1) // ideally relay the copied information to bus units
		else
			// Get a list of relays that we're linked to, then send the signal to their levels.
			relay_information(signal, "/obj/machinery/telecomms/relay", 1)
			relay_information(signal, "/obj/machinery/telecomms/broadcaster", 1) // Send it to a broadcaster.

/obj/machinery/telecomms/hub/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/telecomms/hub(null)
	component_parts += new /obj/item/weapon/stock_parts/subspace/filter(null)
	component_parts += new /obj/item/weapon/stock_parts/subspace/filter(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()






//Preset HUB

/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "s_relay", "m_relay", "r_relay", "science", "medical",
	"supply", "service", "common", "command", "engineering", "security",
	"receiverA", "receiverB", "broadcasterA", "broadcasterB")

