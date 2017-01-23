
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
						var/verb_say, var/verb_ask, var/verb_exclaim, var/verb_yell)

	message = copytext(message, 1, MAX_BROADCAST_LEN)

	if(!message)
		return

	var/list/radios = list()

	var/atom/movable/virtualspeaker/virt = new /atom/movable/virtualspeaker(null)
	virt.name = name
	virt.job = job
	virt.languages_spoken = AM.languages_spoken
	virt.languages_understood = AM.languages_understood
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
		for(var/obj/item/device/radio/intercom/R in all_radios["[freq]"])
			if(R.receive_range(freq, level) > -1)
				radios += R

	// --- Broadcast only to intercoms and station-bounced radios ---

	else if(data == 2)

		for(var/obj/item/device/radio/R in all_radios["[freq]"])
			if(R.subspace_transmission)
				continue

			if(R.receive_range(freq, level) > -1)
				radios += R

	// --- This space left blank for Syndicate data ---

	// --- Centcom radio, yo. ---

	else if(data == 5)

		for(var/obj/item/device/radio/R in all_radios["[freq]"])
			if(!R.centcom)
				continue

			if(R.receive_range(freq, level) > -1)
				radios += R

	// --- Broadcast to ALL radio devices ---

	else
		for(var/obj/item/device/radio/R in all_radios["[freq]"])
			if(R.receive_range(freq, level) > -1)
				radios += R

		var/freqtext = num2text(freq)
		for(var/obj/item/device/radio/R in all_radios["[SYND_FREQ]"]) //syndicate radios use magic that allows them to hear everything. this was already the case, now it just doesn't need the allinone anymore. solves annoying bugs that aren't worth solving.
			if(R.receive_range(SYND_FREQ, list(R.z)) > -1 && freqtext in radiochannelsreverse)
				radios |= R

	// Get a list of mobs who can hear from the radios we collected.
	var/list/receive = get_mobs_in_radio_ranges(radios) //this includes all hearers.

	for(var/mob/R in receive) //Filter receiver list.
		if (R.client && R.client.holder && !(R.client.prefs.chat_toggles & CHAT_RADIO)) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
			receive -= R

	for(var/mob/M in player_list)
		if(isobserver(M) && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTRADIO))
			receive |= M

	var/rendered = virt.compose_message(virt, virt.languages_spoken, message, freq, spans) //Always call this on the virtualspeaker to advoid issues.
	for(var/atom/movable/hearer in receive)
		hearer.Hear(rendered, virt, AM.languages_spoken, message, freq, spans)

	if(length(receive))
		// --- This following recording is intended for research and feedback in the use of department radio channels ---

		var/blackbox_msg = "[AM] [AM.say_quote(message, spans)]"
		if(istype(blackbox))
			switch(freq)
				if(1459)
					blackbox.msg_common += blackbox_msg
				if(1351)
					blackbox.msg_science += blackbox_msg
				if(1353)
					blackbox.msg_command += blackbox_msg
				if(1355)
					blackbox.msg_medical += blackbox_msg
				if(1357)
					blackbox.msg_engineering += blackbox_msg
				if(1359)
					blackbox.msg_security += blackbox_msg
				if(1441)
					blackbox.msg_deathsquad += blackbox_msg
				if(1213)
					blackbox.msg_syndicate += blackbox_msg
				if(1349)
					blackbox.msg_service += blackbox_msg
				if(1347)
					blackbox.msg_cargo += blackbox_msg
				else
					blackbox.messages += blackbox_msg

	spawn(50)
		qdel(virt)

/proc/Broadcast_SimpleMessage(source, frequency, text, data, mob/M, compression, level)

  /* ###### Prepare the radio connection ###### */

	if(!M)
		var/mob/living/carbon/human/H = new
		M = H

	var/datum/radio_frequency/connection = SSradio.return_frequency(frequency)

	var/display_freq = connection.frequency

	var/list/receive = list()


	// --- Broadcast only to intercom devices ---

	if(data == 1)
		for (var/obj/item/device/radio/intercom/R in connection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq, level)


	// --- Broadcast only to intercoms and station-bounced radios ---

	else if(data == 2)
		for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"])
			if(R.subspace_transmission)
				continue
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq)


	// --- Broadcast to syndicate radio! ---

	else if(data == 3)
		var/datum/radio_frequency/syndicateconnection = SSradio.return_frequency(SYND_FREQ)

		for (var/obj/item/device/radio/R in syndicateconnection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(SYND_FREQ)

	// --- Centcom radio, yo. ---

	else if(data == 5)

		for(var/obj/item/device/radio/R in all_radios["[RADIO_CHAT]"])
			if(R.centcom)
				receive |= R.send_hear(CENTCOM_FREQ)

	// --- Broadcast to ALL radio devices ---

	else
		for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq)


  /* ###### Organize the receivers into categories for displaying the message ###### */

	// Understood the message:
	var/list/heard_normal 	= list() // normal message

	// Did not understand the message:
	var/list/heard_garbled	= list() // garbled message (ie "f*c* **u, **i*er!")
	var/list/heard_gibberish= list() // completely screwed over message (ie "F%! (O*# *#!<>&**%!")

	for (var/mob/R in receive)

	  /* --- Loop through the receivers and categorize them --- */

		if (R.client && !(R.client.prefs.chat_toggles & CHAT_RADIO)) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
			continue


		// --- Check for compression ---
		if(compression > 0)

			heard_gibberish += R
			continue

		// --- Can understand the speech ---

		if (R.languages_understood & M.languages_spoken)

			heard_normal += R

		// --- Can't understand the speech ---

		else
			// - Just display a garbled message -

			heard_garbled += R


  /* ###### Begin formatting and sending the message ###### */
	if (length(heard_normal) || length(heard_garbled) || length(heard_gibberish))

	  /* --- Some miscellaneous variables to format the string output --- */
		var/part_a = "<span class='radio'><span class='name'>" // goes in the actual output
		var/freq_text // the name of the channel

		// --- Set the name of the channel ---
		switch(display_freq)

			if(SYND_FREQ)
				freq_text = "#unkn"
			if(COMM_FREQ)
				freq_text = "Command"
			if(SCI_FREQ)
				freq_text = "Science"
			if(MED_FREQ)
				freq_text = "Medical"
			if(ENG_FREQ)
				freq_text = "Engineering"
			if(SEC_FREQ)
				freq_text = "Security"
			if(SERV_FREQ)
				freq_text = "Service"
			if(SUPP_FREQ)
				freq_text = "Supply"
			if(AIPRIV_FREQ)
				freq_text = "AI Private"
		//There's probably a way to use the list var of channels in code\game\communications.dm to make the dept channels non-hardcoded, but I wasn't in an experimentive mood. --NEO


		// --- If the frequency has not been assigned a name, just use the frequency as the name ---

		if(!freq_text)
			freq_text = format_frequency(display_freq)

		// --- Some more pre-message formatting ---

		var/part_b_extra = ""
		if(data == 3) // intercepted radio message
			part_b_extra = " <i>(Intercepted)</i>"

		// Create a radio headset for the sole purpose of using its icon
		var/obj/item/device/radio/headset/radio = new

		var/part_b = "</span><b> \icon[radio]\[[freq_text]\][part_b_extra]</b> <span class='message'>"
		var/part_c = "</span></span>"

		if (display_freq==SYND_FREQ)
			part_a = "<span class='syndradio'><span class='name'>"
		else if (display_freq==COMM_FREQ)
			part_a = "<span class='comradio'><span class='name'>"
		else if (display_freq==SCI_FREQ)
			part_a = "<span class='sciradio'><span class='name'>"
		else if (display_freq==MED_FREQ)
			part_a = "<span class='medradio'><span class='name'>"
		else if (display_freq==ENG_FREQ)
			part_a = "<span class='engradio'><span class='name'>"
		else if (display_freq==SEC_FREQ)
			part_a = "<span class='secradio'><span class='name'>"
		else if (display_freq==SERV_FREQ)
			part_a = "<span class='servradio'><span class='name'>"
		else if (display_freq==SUPP_FREQ)
			part_a = "<span class='suppradio'><span class='name'>"
		else if (display_freq==CENTCOM_FREQ)
			part_a = "<span class='centcomradio'><span class='name'>"
		else if (display_freq==AIPRIV_FREQ)
			part_a = "<span class='aiprivradio'><span class='name'>"

		// --- This following recording is intended for research and feedback in the use of department radio channels ---

		var/part_blackbox_b = "</span><b> \[[freq_text]\]</b> <span class='message'>"
		var/blackbox_msg = "[part_a][source][part_blackbox_b]\"[text]\"[part_c]"
		//var/blackbox_admin_msg = "[part_a][M.name] (Real name: [M.real_name])[part_blackbox_b][quotedmsg][part_c]"

		//BR.messages_admin += blackbox_admin_msg
		if(istype(blackbox))
			switch(display_freq)
				if(1459)
					blackbox.msg_common += blackbox_msg
				if(1351)
					blackbox.msg_science += blackbox_msg
				if(1353)
					blackbox.msg_command += blackbox_msg
				if(1355)
					blackbox.msg_medical += blackbox_msg
				if(1357)
					blackbox.msg_engineering += blackbox_msg
				if(1359)
					blackbox.msg_security += blackbox_msg
				if(1441)
					blackbox.msg_deathsquad += blackbox_msg
				if(1213)
					blackbox.msg_syndicate += blackbox_msg
				if(1349)
					blackbox.msg_service += blackbox_msg
				if(1347)
					blackbox.msg_cargo += blackbox_msg
				else
					blackbox.messages += blackbox_msg

		//End of research and feedback code.

	 /* ###### Send the message ###### */

		/* --- Process all the mobs that heard the voice normally (understood) --- */

		if (length(heard_normal))
			var/rendered = "[part_a][source][part_b]\"[text]\"[part_c]"

			for (var/mob/R in heard_normal)
				R.show_message(rendered, 2)

		/* --- Process all the mobs that heard a garbled voice (did not understand) --- */
			// Displays garbled message (ie "f*c* **u, **i*er!")

		if (length(heard_garbled))
			var/quotedmsg = "\"[stars(text)]\""
			var/rendered = "[part_a][source][part_b][quotedmsg][part_c]"

			for (var/mob/R in heard_garbled)
				R.show_message(rendered, 2)


		/* --- Complete gibberish. Usually happens when there's a compressed message --- */

		if (length(heard_gibberish))
			var/quotedmsg = "\"[Gibberish(text, compression + 50)]\""
			var/rendered = "[part_a][Gibberish(source, compression + 50)][part_b][quotedmsg][part_c]"

			for (var/mob/R in heard_gibberish)
				R.show_message(rendered, 2)

//Use this to test if an obj can communicate with a Telecommunications Network

/atom/proc/test_telecomms()
	var/datum/signal/signal = src.telecomms_process()
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
	for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
		R.receive_signal(signal)

	sleep(rand(10,25))

	return signal

