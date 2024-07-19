// Subtype of /datum/signal with additional processing information.
/datum/signal/subspace
	transmission_method = TRANSMISSION_SUBSPACE
	/// The type of server this signal is meant to be relayed to.
	/// Not exclusive, the bus will usually try to send it through
	/// more signals, but for that look for
	/// `/obj/machinery/telecomms/bus/receive_information()`
	var/server_type = /obj/machinery/telecomms/server
	/// The signal that was the origin of this one, in case it was a copy.
	var/datum/signal/subspace/original
	/// The levels on which this signal can be received. Generally set by
	/// a broadcaster, a relay or a message server.
	/// If this list contains `0`, then it will be receivable on every single
	/// z-level.
	var/list/levels
	/// Blacklisted spans we don't want being put into comms by anything, ever - a place to put any new spans we want to make without letting them annoy people on comms
	var/list/blacklisted_spans = list(
		SPAN_SOAPBOX,
	)

/datum/signal/subspace/New(data)
	src.data = data || list()

/**
 * Handles creating a new subspace signal that's a hard copy of this one, linked
 * to this current signal via the `original` value, so that it can be traced back.
 */
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

/**
 * Handles marking the current signal, as well as its original signal,
 * and their original signals (recursively) as done, in their `data["done"]`.
 */
/datum/signal/subspace/proc/mark_done()
	var/datum/signal/subspace/current = src
	while (current)
		current.data["done"] = TRUE
		current = current.original

/**
 * Handles sending this signal to every available receiver and mainframe.
 */
/datum/signal/subspace/proc/send_to_receivers()
	for(var/obj/machinery/telecomms/receiver/receiver in GLOB.telecomms_list)
		receiver.receive_signal(src)
	for(var/obj/machinery/telecomms/allinone/all_in_one_receiver in GLOB.telecomms_list)
		all_in_one_receiver.receive_signal(src)

/// Handles broadcasting this signal out, to be implemented by subtypes.
/datum/signal/subspace/proc/broadcast()
	set waitfor = FALSE

// Vocal transmissions (i.e. using saycode).
// Despite "subspace" in the name, these transmissions can also be RADIO
// (intercoms and SBRs) or SUPERSPACE (CentCom).
/datum/signal/subspace/vocal
	/// The virtualspeaker associated with this vocal transmission.
	var/atom/movable/virtualspeaker/virt
	/// The language this vocal transmission was sent in.
	var/datum/language/language

#define COMPRESSION_VOCAL_SIGNAL_MIN 35
#define COMPRESSION_VOCAL_SIGNAL_MAX 65

/datum/signal/subspace/vocal/New(
	obj/source,  // the originating radio
	frequency,  // the frequency the signal is taking place on
	atom/movable/virtualspeaker/speaker,  // representation of the method's speaker
	datum/language/language,  // the language of the message
	message,  // the text content of the message
	spans,  // the list of spans applied to the message
	list/message_mods, // the list of modification applied to the message. Whispering, singing, ect
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
		"compression" = rand(COMPRESSION_VOCAL_SIGNAL_MIN, COMPRESSION_VOCAL_SIGNAL_MAX),
		"language" = lang_instance.name,
		"spans" = spans,
		"mods" = message_mods,
	)
	levels = SSmapping.get_connected_levels(get_turf(source))

#undef COMPRESSION_VOCAL_SIGNAL_MIN
#undef COMPRESSION_VOCAL_SIGNAL_MAX

/datum/signal/subspace/vocal/copy()
	var/datum/signal/subspace/vocal/copy = new(source, frequency, virt, language)
	copy.original = src
	copy.data = data.Copy()
	copy.levels = levels
	return copy

/// Past this amount of compression, the resulting gibberish will actually
/// replace characters, making it even harder to understand.
#define COMPRESSION_REPLACE_CHARACTER_THRESHOLD 30

/// This is the meat function for making radios hear vocal transmissions.
/datum/signal/subspace/vocal/broadcast()
	set waitfor = FALSE

	// Perform final composition steps on the message.
	var/message = copytext_char(data["message"], 1, MAX_BROADCAST_LEN)
	if(!message)
		return
	var/compression = data["compression"]
	if(compression > 0)
		message = Gibberish(message, compression >= COMPRESSION_REPLACE_CHARACTER_THRESHOLD)

	var/list/signal_reaches_every_z_level = levels

	if(0 in levels)
		signal_reaches_every_z_level = RADIO_NO_Z_LEVEL_RESTRICTION

	// Assemble the list of radios
	var/list/radios = list()
	switch (transmission_method)
		if (TRANSMISSION_SUBSPACE)
			// Reaches any radios on the levels
			var/list/all_radios_of_our_frequency = GLOB.all_radios["[frequency]"]
			if(LAZYLEN(all_radios_of_our_frequency))
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
				if(!non_subspace_radio.subspace_transmission && non_subspace_radio.can_receive(frequency, signal_reaches_every_z_level))
					radios += non_subspace_radio

		if (TRANSMISSION_SUPERSPACE)
			// Only radios which are independent
			for(var/obj/item/radio/independent_radio in GLOB.all_radios["[frequency]"])
				if(independent_radio.independent && independent_radio.can_receive(frequency, signal_reaches_every_z_level))
					radios += independent_radio

	for(var/obj/item/radio/called_radio as anything in radios)
		called_radio.on_receive_message(data)

	// From the list of radios, find all mobs who can hear those.
	var/list/receive = get_hearers_in_radio_ranges(radios)

	// Add observers who have ghost radio enabled.
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(get_chat_toggles(ghost.client) & CHAT_GHOSTRADIO)
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
		spans -= blacklisted_spans
		hearer.Hear(rendered, virt, language, message, frequency, spans, message_mods, message_range = INFINITY)

	// This following recording is intended for research and feedback in the use of department radio channels
	if(length(receive))
		SSblackbox.LogBroadcast(frequency)

	var/spans_part = ""
	if(length(spans))
		spans_part = "(spans:"
		for(var/span in spans)
			spans_part = "[spans_part] [span]"
		spans_part = "[spans_part] ) "

	var/lang_name = data["language"]
	var/log_text = "\[[get_radio_name(frequency)]\] [spans_part]\"[message]\" (language: [lang_name])"

	var/mob/source_mob = virt.source

	if(ismob(source_mob))
		source_mob.log_message(log_text, LOG_TELECOMMS)
	else
		log_telecomms("[virt.source] [log_text] [loc_name(get_turf(virt.source))]")

	QDEL_IN(virt, 5 SECONDS)  // Make extra sure the virtualspeaker gets qdeleted

#undef COMPRESSION_REPLACE_CHARACTER_THRESHOLD
