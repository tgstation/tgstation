/**
 * Basically just an empty shell for receiving and broadcasting radio messages. Not
 * very flexible, but it gets the job done.
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
	/// List of all frequencies to their name/color
	var/static/alist/frequency_infos = alist(
		"[FREQ_SCIENCE]" = list(
			"name" = RADIO_CHANNEL_SCIENCE,
			"color" = RADIO_COLOR_SCIENCE
		),
		"[FREQ_MEDICAL]" = list(
			"name" = RADIO_CHANNEL_MEDICAL,
			"color" = RADIO_COLOR_MEDICAL
		),
		"[FREQ_SUPPLY]" = list(
			"name" = RADIO_CHANNEL_SUPPLY,
			"color" = RADIO_COLOR_SUPPLY
		),
		"[FREQ_SERVICE]" = list(
			"name" = RADIO_CHANNEL_SERVICE,
			"color" = RADIO_COLOR_SERVICE
		),
		"[FREQ_ENTERTAINMENT]" = list(
			"name" = RADIO_CHANNEL_ENTERTAINMENT,
			"color" = RADIO_COLOR_ENTERTAIMENT
		),
		"[FREQ_COMMON]" = list(
			"name" = RADIO_CHANNEL_COMMON,
			"color" = RADIO_COLOR_COMMON
		),
		"[FREQ_AI_PRIVATE]" = list(
			"name" = RADIO_CHANNEL_AI_PRIVATE,
			"color" = RADIO_COLOR_AI_PRIVATE
		),
		"[FREQ_COMMAND]" = list(
			"name" = RADIO_CHANNEL_COMMAND,
			"color" = RADIO_COLOR_COMMAND
		),
		"[FREQ_ENGINEERING]" = list(
			"name" = RADIO_CHANNEL_ENGINEERING,
			"color" = RADIO_COLOR_ENGINEERING
		),
		"[FREQ_SECURITY]" = list(
			"name" = RADIO_CHANNEL_SECURITY,
			"color" = RADIO_COLOR_SECURITY
		)
	)

/obj/machinery/telecomms/allinone/nuclear
	name = "advanced telecommunications mainframe"
	desc = "A modified mainframe that allows for the processing of priority syndicate subspace telecommunications."
	freq_listening = list(FREQ_SYNDICATE)
	syndicate = TRUE

/obj/machinery/telecomms/allinone/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/telecomms/allinone/indestructible/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/telecomms/allinone/indestructible/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/telecomms/allinone/receive_signal(datum/signal/subspace/signal)
	if(!istype(signal) || signal.transmission_method != TRANSMISSION_SUBSPACE)  // receives on subspace only
		return
	if(!on || !is_freq_listening(signal))  // has to be on to receive messages
		return
	if(!syndicate && !(z in signal.levels) && !(RADIO_NO_Z_LEVEL_RESTRICTION in signal.levels))  // has to be syndicate or on the right level
		return

	var/freq_info = frequency_infos["[signal.frequency]"]
	if(freq_info)
		signal.data["frequency_name"] = freq_info["name"]
		signal.data["frequency_color"] = freq_info["color"]

	// Decompress the signal and mark it done
	if(syndicate)
		signal.levels = list(0)  // Signal is broadcast to agents anywhere

	signal.data["compression"] = 0
	signal.mark_done()
	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"]) // simulate the network lag if necessary
	signal.broadcast()

/obj/machinery/telecomms/allinone/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item.tool_behaviour == TOOL_MULTITOOL)
		return attack_hand(user)
