/// Global list of recent messages broadcasted : used to circumvent massive radio spam
GLOBAL_LIST_EMPTY(recent_messages)
/// Used to make sure restarting the recent_messages list is kept in sync.
GLOBAL_VAR_INIT(message_delay, FALSE)

/**
 * The broadcaster sends processed messages to all radio devices in the game. They
 * do not have to be headsets; intercoms and station-bounced radios suffice.
 *
 * They receive their message from a server after the message has been logged.
 */
/obj/machinery/telecomms/broadcaster
	name = "subspace broadcaster"
	icon_state = "broadcaster"
	desc = "A dish-shaped machine used to broadcast processed subspace signals."
	telecomms_type = /obj/machinery/telecomms/broadcaster
	density = TRUE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.01
	circuit = /obj/item/circuitboard/machine/telecomms/broadcaster

/obj/machinery/telecomms/broadcaster/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	if(!istype(signal))
		return

	// Don't broadcast rejected signals
	if(signal.data["reject"])
		return
	if(!signal.data["message"])
		return

	var/signal_message = "[signal.frequency]:[signal.data["message"]]:[signal.data["name"]]"
	if(signal_message in GLOB.recent_messages)
		return

	// Prevents massive radio spam
	signal.mark_done()
	var/datum/signal/subspace/original = signal.original
	if(original && ("compression" in signal.data))
		original.data["compression"] = signal.data["compression"]

	var/turf/current_turf = get_turf(src)
	if (current_turf)
		signal.levels |= SSmapping.get_connected_levels(current_turf)

	GLOB.recent_messages.Add(signal_message)

	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"]) // simulate the network lag if necessary

	signal.broadcast()

	if(!GLOB.message_delay)
		GLOB.message_delay = TRUE
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(end_message_delay)), 1 SECONDS)

	/* --- Do a snazzy animation! --- */
	flick("broadcaster_send", src)

	use_energy(idle_power_usage)

/**
 * Simply resets the message delay and the recent messages list, to ensure that
 * recent messages can be sent again. Is called on a one second timer after a
 * delay is set, from `/obj/machinery/telecomms/broadcaster/receive_information()`
 */
/proc/end_message_delay()
	GLOB.message_delay = FALSE
	GLOB.recent_messages = list()

/obj/machinery/telecomms/broadcaster/Destroy()
	// In case message_delay is left on 1, otherwise it won't reset the list and people can't say the same thing twice anymore.
	if(GLOB.message_delay)
		GLOB.message_delay = FALSE
	return ..()


// Preset Broadcasters

//--PRESET LEFT--//
/obj/machinery/telecomms/broadcaster/preset_left
	id = "Broadcaster A"
	network = "tcommsat"
	autolinkers = list("broadcasterA")

//--PRESET RIGHT--//
/obj/machinery/telecomms/broadcaster/preset_right
	id = "Broadcaster B"
	network = "tcommsat"
	autolinkers = list("broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_left/birdstation
	name = "Broadcaster"
