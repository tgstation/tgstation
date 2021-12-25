/*

	Here is the big, bad function that broadcasts a message given the appropriate
	parameters.

	@param M:
		Reference to the mob/speaker, stored in signal.data["mob"]

	@param vmask:
		Boolean value if the mob is "hiding" its identity via voice mask, stored in
		signal.data["vmask"]

	@param vmessage:
		If specified, will display this as the message; such as "chimpering"
		for monkeys if the mob is not understood. Stored in signal.data["vmessage"].

	@param radio:
		Reference to the radio broadcasting the message, stored in signal.data["radio"]

	@param message:
		The actual string message to display to mobs who understood mob M. Stored in
		signal.data["message"]

	@param name:
		The name to display when a mob receives the message. signal.data["name"]

	@param job:
		The name job to display for the AI when it receives the message. signal.data["job"]

	@param realname:
		The "real" name associated with the mob. signal.data["realname"]

	@param vname:
		If specified, will use this name when mob M is not understood. signal.data["vname"]

	@param data:
		If specified:
				1 -- Will only broadcast to intercoms
				2 -- Will only broadcast to intercoms and station-bounced radios
				3 -- Broadcast to syndicate frequency
				4 -- AI can't track down this person. Useful for imitation broadcasts where you can't find the actual mob

	@param compression:
		If 0, the signal is audible
		If nonzero, the signal may be partially inaudible or just complete gibberish.

	@param level:
		The list of Z levels that the sending radio is broadcasting to. Having 0 in the list broadcasts on all levels

	@param freq
		The frequency of the signal

**/

// Subtype of /datum/signal with additional processing information.
/datum/signal/subspace
	transmission_method = TRANSMISSION_SUBSPACE
	var/server_type = /obj/machinery/telecomms/server
	var/datum/signal/subspace/original
	var/list/levels

/datum/signal/subspace/New(data)
	src.data = data || list()

/datum/signal/subspace/proc/copy()
	var/datum/signal/subspace/copy = new
	copy.original = src
	copy.source = source
	copy.levels = levels
	copy.frequency = frequency
	copy.server_type = server_type
	copy.transmission_method = transmission_method
	copy.data = data.Copy()
	return copy

/datum/signal/subspace/proc/mark_done()
	var/datum/signal/subspace/current = src
	while (current)
		current.data["done"] = TRUE
		current = current.original

/datum/signal/subspace/proc/send_to_receivers()
	for(var/obj/machinery/telecomms/receiver/R in GLOB.telecomms_list)
		R.receive_signal(src)
	for(var/obj/machinery/telecomms/allinone/R in GLOB.telecomms_list)
		R.receive_signal(src)

/datum/signal/subspace/proc/broadcast()
	set waitfor = FALSE

// Vocal transmissions (i.e. using saycode).
// Despite "subspace" in the name, these transmissions can also be RADIO
// (intercoms and SBRs) or SUPERSPACE (CentCom).
/datum/signal/subspace/vocal
	var/atom/movable/virtualspeaker/virt
	var/datum/language/language

/datum/signal/subspace/vocal/New(
	obj/source,  // the originating radio
	frequency,  // the frequency the signal is taking place on
	atom/movable/virtualspeaker/speaker,  // representation of the method's speaker
	datum/language/language,  // the language of the message
	message,  // the text content of the message
	spans,  // the list of spans applied to the message
	list/message_mods // the list of modification applied to the message. Whispering, singing, ect
)
	src.source = source
	src.frequency = frequency
	src.language = language
	virt = speaker
	var/datum/language/lang_instance = GLOB.language_datum_instances[language]
	data = list(
		"name" = speaker.name,
		"job" = speaker.job,
		"message" = message,
		"compression" = rand(35, 65),
		"language" = lang_instance.name,
		"spans" = spans,
		"mods" = message_mods
	)
	var/turf/T = get_turf(source)
	levels = list(T.z)

/datum/signal/subspace/vocal/copy()
	var/datum/signal/subspace/vocal/copy = new(source, frequency, virt, language)
	copy.original = src
	copy.data = data.Copy()
	copy.levels = levels
	return copy

/// This is the meat function for making radios hear vocal transmissions.
/datum/signal/subspace/vocal/broadcast()
	set waitfor = FALSE

	// Perform final composition steps on the message.
	var/message = copytext_char(data["message"], 1, MAX_BROADCAST_LEN)
	if(!message)
		return
	var/compression = data["compression"]
	if(compression > 0)
		message = Gibberish(message, compression >= 30)

	var/list/signal_reaches_every_z_level = levels

	if(0 in levels)
		signal_reaches_every_z_level = RADIO_NO_Z_LEVEL_RESTRICTION

	// Assemble the list of radios
	var/list/radios = list()
	switch (transmission_method)
		if (TRANSMISSION_SUBSPACE)
			// Reaches any radios on the levels
			var/list/all_radios_of_our_frequency = GLOB.all_radios["[frequency]"]
			radios = all_radios_of_our_frequency.Copy()

			for(var/obj/item/radio/subspace_radio in radios)
				if(!subspace_radio.can_receive(frequency, signal_reaches_every_z_level))
					radios -= subspace_radio

			// Syndicate radios can hear all well-known radio channels
			if (num2text(frequency) in GLOB.reverseradiochannels)
				for(var/obj/item/radio/syndicate_radios in GLOB.all_radios["[FREQ_SYNDICATE]"])
					if(syndicate_radios.can_receive(FREQ_SYNDICATE, RADIO_NO_Z_LEVEL_RESTRICTION))
						radios |= syndicate_radios

		if (TRANSMISSION_RADIO)
			// Only radios not currently in subspace mode
			for(var/obj/item/radio/non_subspace_radio in GLOB.all_radios["[frequency]"])
				if(!non_subspace_radio.subspace_transmission && non_subspace_radio.can_receive(frequency, levels))
					radios += non_subspace_radio

		if (TRANSMISSION_SUPERSPACE)
			// Only radios which are independent
			for(var/obj/item/radio/independent_radio in GLOB.all_radios["[frequency]"])
				if(independent_radio.independent && independent_radio.can_receive(frequency, levels))
					radios += independent_radio

	// From the list of radios, find all mobs who can hear those.
	var/list/receive = get_hearers_in_radio_ranges(radios)

	// Add observers who have ghost radio enabled.
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(ghost.client.prefs?.chat_toggles & CHAT_GHOSTRADIO)
			receive |= ghost

	// Render the message and have everybody hear it.
	// Always call this on the virtualspeaker to avoid issues.
	var/spans = data["spans"]
	var/list/message_mods = data["mods"]
	var/rendered = virt.compose_message(virt, language, message, frequency, spans)

	for(var/atom/movable/hearer as anything in receive)
		if(!hearer)
			stack_trace("null found in the hearers list returned by the spatial grid. this is bad")
			continue

		hearer.Hear(rendered, virt, language, message, frequency, spans, message_mods)

	// This following recording is intended for research and feedback in the use of department radio channels
	if(length(receive))
		SSblackbox.LogBroadcast(frequency)

	var/spans_part = ""
	if(length(spans))
		spans_part = "(spans:"
		for(var/S in spans)
			spans_part = "[spans_part] [S]"
		spans_part = "[spans_part] ) "

	var/lang_name = data["language"]
	var/log_text = "\[[get_radio_name(frequency)]\] [spans_part]\"[message]\" (language: [lang_name])"

	var/mob/source_mob = virt.source

	if(ismob(source_mob))
		source_mob.log_message(log_text, LOG_TELECOMMS)
	else
		log_telecomms("[virt.source] [log_text] [loc_name(get_turf(virt.source))]")

	QDEL_IN(virt, 50)  // Make extra sure the virtualspeaker gets qdeleted
