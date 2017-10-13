
/**

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


/proc/Broadcast_Message(var/atom/movable/AM,
						var/vmask, var/obj/item/device/radio/radio,
						var/message, var/name, var/job, var/realname,
						var/data, var/compression, var/list/level, var/freq, var/list/spans,
						var/verb_say, var/verb_ask, var/verb_exclaim, var/verb_yell, var/datum/language/language)

	set waitfor = FALSE

	message = copytext(message, 1, MAX_BROADCAST_LEN)

	if(!message)
		return

	var/list/radios = list()

	var/atom/movable/virtualspeaker/virt = new /atom/movable/virtualspeaker(null)
	virt.name = name
	virt.job = job
	virt.source = AM
	virt.radio = radio
	virt.verb_say = verb_say
	virt.verb_ask = verb_ask
	virt.verb_exclaim = verb_exclaim
	virt.verb_yell = verb_yell

	if(compression > 0)
		message = Gibberish(message, compression + 40)

	// --- Broadcast only to intercom devices ---

	if(data == 1)
		for(var/obj/item/device/radio/intercom/R in GLOB.all_radios["[freq]"])
			if(R.receive_range(freq, level) > -1)
				radios += R

	// --- Broadcast only to intercoms and station-bounced radios ---

	else if(data == 2)

		for(var/obj/item/device/radio/R in GLOB.all_radios["[freq]"])
			if(R.subspace_transmission)
				continue

			if(R.receive_range(freq, level) > -1)
				radios += R

	// --- This space left blank for Syndicate data ---

	// --- CentCom radio, yo. ---

	else if(data == 5)

		for(var/obj/item/device/radio/R in GLOB.all_radios["[freq]"])
			if(!R.independent)
				continue

			if(R.receive_range(freq, level) > -1)
				radios += R

	// --- Broadcast to ALL radio devices ---

	else
		for(var/obj/item/device/radio/R in GLOB.all_radios["[freq]"])
			if(R.receive_range(freq, level) > -1)
				radios += R

		var/freqtext = num2text(freq)
		for(var/obj/item/device/radio/R in GLOB.all_radios["[GLOB.SYND_FREQ]"]) //syndicate radios use magic that allows them to hear everything. this was already the case, now it just doesn't need the allinone anymore. solves annoying bugs that aren't worth solving.
			if(R.receive_range(GLOB.SYND_FREQ, list(R.z)) > -1 && freqtext in GLOB.reverseradiochannels)
				radios |= R

	// Get a list of mobs who can hear from the radios we collected.
	var/list/receive = get_mobs_in_radio_ranges(radios) //this includes all hearers.

	for(var/mob/R in receive) //Filter receiver list.
		if (R.client && R.client.holder && !(R.client.prefs.chat_toggles & CHAT_RADIO)) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
			receive -= R

	for(var/mob/M in GLOB.player_list)
		if(isobserver(M) && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTRADIO))
			receive |= M

	var/rendered = virt.compose_message(virt, language, message, freq, spans) //Always call this on the virtualspeaker to advoid issues.
	for(var/atom/movable/hearer in receive)
		hearer.Hear(rendered, virt, language, message, freq, spans)

	if(length(receive))
		// --- This following recording is intended for research and feedback in the use of department radio channels ---

		var/blackbox_msg = "[AM] [AM.say_quote(message, spans)]"
		SSblackbox.LogBroadcast(blackbox_msg, freq)

	sleep(50)
	if(!QDELETED(virt)) //It could happen to YOU
		qdel(virt)

//Use this to test if an obj can communicate with a Telecommunications Network

/atom/proc/test_telecomms()
	var/datum/signal/signal = telecomms_process()
	var/turf/position = get_turf(src)
	return (position.z in signal.data["level"] && signal.data["done"])

/atom/proc/telecomms_process()

	// First, we want to generate a new radio signal
	var/datum/signal/signal = new
	signal.transmission_method = 2 // 2 would be a subspace transmission.
	var/turf/pos = get_turf(src)

	// --- Finally, tag the actual signal with the appropriate values ---
	signal.data = list(
		"slow" = 0, // how much to sleep() before broadcasting - simulates net lag
		"message" = "TEST",
		"compression" = rand(45, 50), // If the signal is compressed, compress our message too.
		"traffic" = 0, // dictates the total traffic sum that the signal went through
		"type" = 4, // determines what type of radio input it is: test broadcast
		"reject" = 0,
		"done" = 0,
		"level" = pos.z // The level it is being broadcasted at.
	)
	signal.frequency = 1459// Common channel

  //#### Sending the signal to all subspace receivers ####//
	for(var/obj/machinery/telecomms/receiver/R in GLOB.telecomms_list)
		R.receive_signal(signal)

	sleep(rand(10,25))

	return signal
