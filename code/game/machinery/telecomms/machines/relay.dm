/*
	The relay idles until it receives information. It then passes on that information
	depending on where it came from.

	The relay is needed in order to send information pass Z levels. It must be linked
	with a HUB, the only other machine that can send/receive pass Z levels.
*/

/obj/machinery/telecomms/relay
	name = "telecommunication relay"
	icon_state = "relay"
	desc = "A mighty piece of hardware used to send massive amounts of data far away."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	machinetype = 8
	netspeed = 5
	long_range_link = 1
	circuit = /obj/item/weapon/circuitboard/machine/telecomms/relay
	var/broadcasting = 1
	var/receiving = 1

/obj/machinery/telecomms/relay/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	// Add our level and send it back
	if(can_send(signal))
		signal.data["level"] |= listening_level

// Checks to see if it can send/receive.

/obj/machinery/telecomms/relay/proc/can(datum/signal/signal)
	if(!on)
		return FALSE
	if(!is_freq_listening(signal))
		return FALSE
	return TRUE

/obj/machinery/telecomms/relay/proc/can_send(datum/signal/signal)
	if(!can(signal))
		return FALSE
	return broadcasting

/obj/machinery/telecomms/relay/proc/can_receive(datum/signal/signal)
	if(!can(signal))
		return FALSE
	return receiving

//Preset Relay

/obj/machinery/telecomms/relay/preset
	network = "tcommsat"

/obj/machinery/telecomms/relay/preset/station
	id = "Station Relay"
	listening_level = 1
	autolinkers = list("s_relay")

/obj/machinery/telecomms/relay/preset/telecomms
	id = "Telecomms Relay"
	autolinkers = list("relay")

/obj/machinery/telecomms/relay/preset/mining
	id = "Mining Relay"
	autolinkers = list("m_relay")

/obj/machinery/telecomms/relay/preset/ruskie
	id = "Ruskie Relay"
	hide = 1
	toggled = FALSE
	autolinkers = list("r_relay")
