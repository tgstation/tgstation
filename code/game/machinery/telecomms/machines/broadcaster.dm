/*
	The broadcaster sends processed messages to all radio devices in the game. They
	do not have to be headsets; intercoms and station-bounced radios suffice.

	They receive their message from a server after the message has been logged.
*/

GLOBAL_LIST_EMPTY(recentmessages) // global list of recent messages broadcasted : used to circumvent massive radio spam
GLOBAL_VAR_INIT(message_delay, 0) // To make sure restarting the recentmessages list is kept in sync

/obj/machinery/telecomms/broadcaster
	name = "subspace broadcaster"
	icon_state = "broadcaster"
	desc = "A dish-shaped machine used to broadcast processed subspace signals."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 25
	machinetype = 5
	circuit = /obj/item/circuitboard/machine/telecomms/broadcaster

/obj/machinery/telecomms/broadcaster/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	// Don't broadcast rejected signals
	if(signal.data["reject"])
		return

	if(signal.data["message"])


		// Prevents massive radio spam
		signal.data["done"] = 1 // mark the signal as being broadcasted
		// Search for the original signal and mark it as done as well
		var/datum/signal/original = signal.data["original"]
		if(original)
			original.data["done"] = 1
			original.data["compression"] = signal.data["compression"]
			original.data["level"] = signal.data["level"]

		var/signal_message = "[signal.frequency]:[signal.data["message"]]:[signal.data["realname"]]"
		if(signal_message in GLOB.recentmessages)
			return
		GLOB.recentmessages.Add(signal_message)

		if(signal.data["slow"] > 0)
			sleep(signal.data["slow"]) // simulate the network lag if necessary

		signal.data["level"] |= listening_level

	   /** #### - Normal Broadcast - #### **/

		if(signal.data["type"] == 0)

			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(signal.data["mob"],
							  signal.data["vmask"], signal.data["radio"],
							  signal.data["message"], signal.data["name"], signal.data["job"], signal.data["realname"],
							  0, signal.data["compression"], signal.data["level"], signal.frequency, signal.data["spans"],
							  signal.data["verb_say"], signal.data["verb_ask"], signal.data["verb_exclaim"], signal.data["verb_yell"], signal.data["language"])


	   /** #### - Artificial Broadcast - #### **/
	   			// (Imitates a mob)

		if(signal.data["type"] == 2)

			/* ###### Broadcast a message using signal.data ###### */
				// Parameter "data" as 4: AI can't track this person/mob
			Broadcast_Message(signal.data["mob"],
							  signal.data["vmask"],
							  signal.data["radio"], signal.data["message"],
							  signal.data["name"], signal.data["job"],
							  signal.data["realname"], 4, signal.data["compression"], signal.data["level"], signal.frequency, signal.data["spans"],
							  signal.data["verb_say"], signal.data["verb_ask"], signal.data["verb_exclaim"], signal.data["verb_yell"], signal.data["language"])

		if(!GLOB.message_delay)
			GLOB.message_delay = 1
			spawn(10)
				GLOB.message_delay = 0
				GLOB.recentmessages = list()

		/* --- Do a snazzy animation! --- */
		flick("broadcaster_send", src)

/obj/machinery/telecomms/broadcaster/Destroy()
	// In case message_delay is left on 1, otherwise it won't reset the list and people can't say the same thing twice anymore.
	if(GLOB.message_delay)
		GLOB.message_delay = 0
	return ..()



//Preset Broadcasters

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
