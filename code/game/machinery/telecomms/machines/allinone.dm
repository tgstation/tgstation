/*
	Basically just an empty shell for receiving and broadcasting radio messages. Not
	very flexible, but it gets the job done.
*/

/obj/machinery/telecomms/allinone
	name = "telecommunications mainframe"
	icon_state = "comm_server"
	desc = "A compact machine used for portable subspace telecommuniations processing."
	density = 1
	anchored = 1
	use_power = NO_POWER_USE
	idle_power_usage = 0
	machinetype = 6
	var/intercept = 0 // if nonzero, broadcasts all messages to syndicate channel

/obj/machinery/telecomms/allinone/receive_signal(datum/signal/signal)

	if(!on) // has to be on to receive messages
		return

	if(is_freq_listening(signal)) // detect subspace signals

		signal.data["done"] = 1 // mark the signal as being broadcasted
		signal.data["compression"] = 0

		// Search for the original signal and mark it as done as well
		var/datum/signal/original = signal.data["original"]
		if(original)
			original.data["done"] = 1

		if(signal.data["slow"] > 0)
			sleep(signal.data["slow"]) // simulate the network lag if necessary

		/* ###### Broadcast a message using signal.data ###### */
		if(signal.frequency == GLOB.SYND_FREQ) // if syndicate broadcast, just
			Broadcast_Message(signal.data["mob"],
							  signal.data["vmask"],
							  signal.data["radio"], signal.data["message"],
							  signal.data["name"], signal.data["job"],
							  signal.data["realname"],, signal.data["compression"], list(0, z), signal.frequency, signal.data["spans"],
							  signal.data["verb_say"], signal.data["verb_ask"], signal.data["verb_exclaim"], signal.data["verb_yell"],
							  signal.data["language"])

/obj/machinery/telecomms/allinone/attackby(obj/item/P, mob/user, params)

	if(istype(P, /obj/item/device/multitool))
		attack_hand(user)
