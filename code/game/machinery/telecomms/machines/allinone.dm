/*
	Basically just an empty shell for receiving and broadcasting radio messages. Not
	very flexible, but it gets the job done.
*/

/obj/machinery/telecomms/allinone
	name = "telecommunications mainframe"
	icon_state = "comm_server"
	desc = "A compact machine used for portable subspace telecommuniations processing."
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	var/intercept = FALSE  // If true, only works on the Syndicate frequency.

/obj/machinery/telecomms/allinone/Initialize()
	if (intercept)
		freq_listening = list(FREQ_SYNDICATE)

/obj/machinery/telecomms/allinone/receive_signal(datum/signal/subspace/vocal/signal)
	if(!on) // has to be on to receive messages
		return
	if(!is_freq_listening(signal))
		return
	if(!istype(signal))  // can't process non-vocal signals
		return

	// Decompress the signal and mark it done
	signal.data["compression"] = 0
	signal.mark_done()
	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"]) // simulate the network lag if necessary
	signal.send_to_radios()

/obj/machinery/telecomms/allinone/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/device/multitool))
		attack_hand(user)
