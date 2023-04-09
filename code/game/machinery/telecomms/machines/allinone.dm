/*
	Basically just an empty shell for receiving and broadcasting radio messages. Not
	very flexible, but it gets the job done.
*/

/obj/machinery/telecomms/allinone
	name = "telecommunications mainframe"
	icon_state = "comm_server"
	desc = "A compact machine used for portable subspace telecommunications processing."
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	/// If this mainframe can process all syndicate chatter regardless of z level
	var/syndicate = FALSE

/obj/machinery/telecomms/allinone/nuclear
	name = "advanced telecommunications mainframe"
	desc = "A modified mainframe that allows for the processing of priority syndicate subspace telecommunications."
	freq_listening = list(FREQ_SYNDICATE)
	syndicate = TRUE

/obj/machinery/telecomms/allinone/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODECONSTRUCT_1

/obj/machinery/telecomms/allinone/receive_signal(datum/signal/subspace/signal)
	if(!istype(signal) || signal.transmission_method != TRANSMISSION_SUBSPACE)  // receives on subspace only
		return
	if(!on || !is_freq_listening(signal))  // has to be on to receive messages
		return
	if(!syndicate && !(z in signal.levels) && !(0 in signal.levels))  // has to be syndicate or on the right level
		return

	// Decompress the signal and mark it done
	if(syndicate)
		signal.levels = list(0)  // Signal is broadcast to agents anywhere

	signal.data["compression"] = 0
	signal.mark_done()
	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"]) // simulate the network lag if necessary
	signal.broadcast()

/obj/machinery/telecomms/allinone/attackby(obj/item/P, mob/user, params)
	if(P.tool_behaviour == TOOL_MULTITOOL)
		return attack_hand(user)
