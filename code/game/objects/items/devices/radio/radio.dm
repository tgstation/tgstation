/obj/item/device/radio
	icon = 'icons/obj/radio.dmi'
	name = "station bounced radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	dog_fashion = /datum/dog_fashion/back
	var/on = TRUE // 0 for off
	var/last_transmission
	var/frequency = 1459 //common chat
	var/traitor_frequency = 0 //tune to frequency to unlock traitor supplies
	var/canhear_range = 3 // the range which mobs can hear this radio from
	var/obj/item/device/radio/patch_link = null
	var/list/secure_radio_connections
	var/prison_radio = 0
	var/b_stat = 0
	var/broadcasting = 0
	var/listening = 1
	var/translate_binary = 0
	var/freerange = 0 // 0 - Sanitize frequencies, 1 - Full range
	var/list/channels = list() //see communications.dm for full list. First channes is a "default" for :h
	var/obj/item/device/encryptionkey/keyslot //To allow the radio to accept encryption keys.
	var/subspace_switchable = 0
	var/subspace_transmission = 0
	var/syndie = 0//Holder to see if it's a syndicate encrpyed radio
	var/independent = FALSE // If true, bypasses any tcomms machinery.
	var/freqlock = 0 //Frequency lock to stop the user from untuning specialist radios.
	var/emped = 0	//Highjacked to track the number of consecutive EMPs on the radio, allowing consecutive EMP's to stack properly.
//			"Example" = FREQ_LISTENING|FREQ_BROADCASTING
	flags_1 = CONDUCT_1 | HEAR_1
	slot_flags = SLOT_BELT
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=75, MAT_GLASS=25)

	var/const/TRANSMISSION_DELAY = 5 // only 2/second/radio
	var/const/FREQ_LISTENING = 1
		//FREQ_BROADCASTING = 2

	var/command = FALSE //If we are speaking into a command headset, our text can be BOLD
	var/use_command = FALSE

/obj/item/device/radio/proc/set_frequency(new_frequency)
	remove_radio(src, frequency)
	frequency = add_radio(src, new_frequency)

/obj/item/device/radio/proc/recalculateChannels()
	channels = list()
	translate_binary = 0
	syndie = 0
	independent = FALSE

	if(keyslot)
		for(var/ch_name in keyslot.channels)
			if(ch_name in src.channels)
				continue
			channels += ch_name
			channels[ch_name] = keyslot.channels[ch_name]

		if(keyslot.translate_binary)
			translate_binary = 1

		if(keyslot.syndie)
			syndie = 1

		if(keyslot.independent)
			independent = TRUE

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

/obj/item/device/radio/proc/make_syndie() // Turns normal radios into Syndicate radios!
	qdel(keyslot)
	keyslot = new /obj/item/device/encryptionkey/syndicate
	syndie = 1
	recalculateChannels()

/obj/item/device/radio/Destroy()
	qdel(wires)
	wires = null
	remove_radio_all(src) //Just to be sure
	patch_link = null
	keyslot = null
	return ..()

/obj/item/device/radio/Initialize()
	wires = new /datum/wires/radio(src)
	if(prison_radio)
		wires.cut(WIRE_TX) // OH GOD WHY
	secure_radio_connections = new
	. = ..()
	frequency = sanitize_frequency(frequency, freerange)
	set_frequency(frequency)

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

/obj/item/device/radio/interact(mob/user)
	if (..())
		return
	if(b_stat && !isAI(user))
		wires.interact(user)
	else
		ui_interact(user)

/obj/item/device/radio/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "radio", name, 370, 220 + channels.len * 22, master_ui, state)
		ui.open()

/obj/item/device/radio/ui_data(mob/user)
	var/list/data = list()

	data["broadcasting"] = broadcasting
	data["listening"] = listening
	data["frequency"] = frequency
	data["minFrequency"] = freerange ? MIN_FREE_FREQ : MIN_FREQ
	data["maxFrequency"] = freerange ? MAX_FREE_FREQ : MAX_FREQ
	data["freqlock"] = freqlock
	data["channels"] = list()
	for(var/channel in channels)
		data["channels"][channel] = channels[channel] & FREQ_LISTENING
	data["command"] = command
	data["useCommand"] = use_command
	data["subspace"] = subspace_transmission
	data["subspaceSwitchable"] = subspace_switchable
	data["headset"] = istype(src, /obj/item/device/radio/headset)

	return data

/obj/item/device/radio/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("frequency")
			if(freqlock)
				return
			var/tune = params["tune"]
			var/adjust = text2num(params["adjust"])
			if(tune == "input")
				var/min = format_frequency(freerange ? MIN_FREE_FREQ : MIN_FREQ)
				var/max = format_frequency(freerange ? MAX_FREE_FREQ : MAX_FREQ)
				tune = input("Tune frequency ([min]-[max]):", name, format_frequency(frequency)) as null|num
				if(!isnull(tune) && !..())
					. = TRUE
			else if(adjust)
				tune = frequency + adjust * 10
				. = TRUE
			else if(text2num(tune) != null)
				tune = tune * 10
				. = TRUE
			if(.)
				frequency = sanitize_frequency(tune, freerange)
				set_frequency(frequency)
				if(frequency == traitor_frequency && hidden_uplink)
					hidden_uplink.interact(usr)
					ui.close()
		if("listen")
			listening = !listening
			. = TRUE
		if("broadcast")
			broadcasting = !broadcasting
			. = TRUE
		if("channel")
			var/channel = params["channel"]
			if(!(channel in channels))
				return
			if(channels[channel] & FREQ_LISTENING)
				channels[channel] &= ~FREQ_LISTENING
			else
				channels[channel] |= FREQ_LISTENING
			. = TRUE
		if("command")
			use_command = !use_command
			. = TRUE
		if("subspace")
			if(subspace_switchable)
				subspace_transmission = !subspace_transmission
				if(!subspace_transmission)
					channels = list()
				else
					recalculateChannels()
				. = TRUE

/obj/item/device/radio/talk_into(atom/movable/M, message, channel, list/spans, datum/language/language)
	if(!spans)
		spans = M.get_spans()
	if(!language)
		language = M.get_default_language()
	INVOKE_ASYNC(src, .proc/talk_into_impl, M, message, channel, spans, language)
	return ITALICS | REDUCE_RANGE

/obj/item/device/radio/proc/talk_into_impl(atom/movable/M, message, channel, list/spans, datum/language/language)
	if(!on) return // the device has to be on
	//  Fix for permacell radios, but kinda eh about actually fixing them.
	if(!M || !message) return

	if(wires.is_cut(WIRE_TX))
		return

	if(!M.IsVocal())
		return

	if(use_command)
		spans |= SPAN_COMMAND

	/* Quick introduction:
		This new radio system uses a very robust FTL signaling technology unoriginally
		dubbed "subspace" which is somewhat similar to 'blue-space' but can't
		actually transmit large mass. Headsets are the only radio devices capable
		of sending subspace transmissions to the Communications Satellite.

		A headset sends a signal to a subspace listener/reciever elsewhere in space,
		the signal gets processed and logged, and an audible transmission gets sent
		to each individual headset.
	*/

	/*
		be prepared to disregard any comments in all of tcomms code. i tried my best to keep them somewhat up-to-date, but eh
	*/

		//get the frequency you buttface. radios no longer use the SSradio. confusing for future generations, convenient for me.
	var/freq
	if(channel && channels && channels.len > 0)
		if(channel == "department")
			channel = channels[1]
		freq = secure_radio_connections[channel]
		if (!channels[channel]) // if the channel is turned off, don't broadcast
			return
	else
		freq = frequency
		channel = null

	var/freqnum = text2num(freq) //Why should we call text2num three times when we can just do it here?
	var/turf/position = get_turf(src)

	var/jammed = FALSE
	for(var/obj/item/device/jammer/jammer in GLOB.active_jammers)
		if(get_dist(position,get_turf(jammer)) < jammer.range)
			jammed = TRUE
			break

	//#### Tagging the signal with all appropriate identity values ####//

	// ||-- The mob's name identity --||
	var/real_name = M.name // mob's real name
	var/mobkey = "none" // player key associated with mob
	var/voicemask = 0 // the speaker is wearing a voice mask
	var/voice = M.GetVoice() // Why reinvent the wheel when there is a proc that does nice things already
	if(ismob(M))
		var/mob/speaker = M
		real_name = speaker.real_name
		if(speaker.client)
			mobkey = speaker.key // assign the mob's key


	var/jobname // the mob's "job"

	if(jammed)
		message = Gibberish(message,100)

	// --- Human: use their job as seen on the crew manifest - makes it unneeded to carry an ID for an AI to see their job
	if(ishuman(M))
		var/datum/data/record/findjob = find_record("name", voice, GLOB.data_core.general)

		if(voice != real_name)
			voicemask = 1
		if(findjob)
			jobname = findjob.fields["rank"]
		else
			jobname = "Unknown"

	// --- Carbon Nonhuman ---
	else if(iscarbon(M)) // Nonhuman carbon mob
		jobname = "No id"

	// --- AI ---
	else if(isAI(M))
		jobname = "AI"

	// --- Cyborg ---
	else if(iscyborg(M))
		var/mob/living/silicon/robot/B = M
		jobname = "[B.designation] Cyborg"

	// --- Personal AI (pAI) ---
	else if(istype(M, /mob/living/silicon/pai))
		jobname = "Personal AI"

	// --- Cold, emotionless machines. ---
	else if(isobj(M))
		jobname = "Machine"

	// --- Unidentifiable mob ---
	else
		jobname = "Unknown"

	/* ###### `independent` radios bypass all comms relays. ###### */

	if(independent)
		var/datum/signal/signal = new
		signal.transmission_method = 2
		signal.data = list(
			"mob" = M, 				// store a reference to the mob
			"mobtype" = M.type, 	// the mob's type
			"realname" = real_name, // the mob's real name
			"name" = voice,			// the mob's voice name
			"job" = jobname,		// the mob's job
			"key" = mobkey,			// the mob's key
			"vmask" = voicemask,	// 1 if the mob is using a voice gas mas

			"compression" = 0,		// uncompressed radio signal
			"message" = message, 	// the actual sent message
			"radio" = src, 			// stores the radio used for transmission
			"slow" = 0,
			"traffic" = 0,
			"type" = 0,
			"server" = null,
			"reject" = 0,
			"level" = 0,
			"language" = language,
			"spans" = spans,
			"verb_say" = M.verb_say,
			"verb_ask" = M.verb_ask,
			"verb_exclaim" = M.verb_exclaim,
			"verb_yell" = M.verb_yell,
			)
		signal.frequency = freqnum // Quick frequency set
		Broadcast_Message(M, voicemask,
				  src, message, voice, jobname, real_name,
				  5, signal.data["compression"], list(position.z, 0), freq, spans,
				  verb_say, verb_ask, verb_exclaim, verb_yell, language)
		return

	/* ###### Radio headsets can only broadcast through subspace ###### */

	if(subspace_transmission)
		// First, we want to generate a new radio signal
		var/datum/signal/signal = new
		signal.transmission_method = 2 // 2 would be a subspace transmission.
									   // transmission_method could probably be enumerated through #define. Would be neater.
									   // --- Finally, tag the actual signal with the appropriate values ---
		signal.data = list(
			// Identity-associated tags:
			"mob" = M, // store a reference to the mob
			"mobtype" = M.type, 	// the mob's type
			"realname" = real_name, // the mob's real name
			"name" = voice,			// the mob's voice name
			"job" = jobname,		// the mob's job
			"key" = mobkey,			// the mob's key
			"vmask" = voicemask,	// 1 if the mob is using a voice gas mask

			// We store things that would otherwise be kept in the actual mob
			// so that they can be logged even AFTER the mob is deleted or something

			// Other tags:
			"compression" = rand(35,65), // compressed radio signal
			"message" = message, // the actual sent message
			"radio" = src, // stores the radio used for transmission
			"slow" = 0, // how much to sleep() before broadcasting - simulates net lag
			"traffic" = 0, // dictates the total traffic sum that the signal went through
			"type" = 0, // determines what type of radio input it is: normal broadcast
			"server" = null, // the last server to log this signal
			"reject" = 0,	// if nonzero, the signal will not be accepted by any broadcasting machinery
			"level" = position.z, // The source's z level
			"language" = language,
			"spans" = spans, //the span classes of this message.
			"verb_say" = M.verb_say, //the verb used when talking normally
			"verb_ask" = M.verb_ask, //the verb used when asking
			"verb_exclaim" = M.verb_exclaim, //the verb used when exclaiming
			"verb_yell" = M.verb_yell //the verb used when yelling
			)
		signal.frequency = freq

		 //#### Sending the signal to all subspace receivers ####//

		for(var/obj/machinery/telecomms/receiver/R in GLOB.telecomms_list)
			R.receive_signal(signal)

		// Allinone can act as receivers.
		for(var/obj/machinery/telecomms/allinone/R in GLOB.telecomms_list)
			R.receive_signal(signal)

		// Receiving code can be located in Telecommunications.dm
		return


	 /* ###### Intercoms and station-bounced radios ###### */

	var/filter_type = 2

	var/datum/signal/signal = new
	signal.transmission_method = 2


	/* --- Try to send a normal subspace broadcast first */

	signal.data = list(
		"mob" = M, 				// store a reference to the mob
		"mobtype" = M.type, 	// the mob's type
		"realname" = real_name, // the mob's real name
		"name" = voice,			// the mob's voice name
		"job" = jobname,		// the mob's job
		"key" = mobkey,			// the mob's key
		"vmask" = voicemask,	// 1 if the mob is using a voice gas mas

		"compression" = 0,		// uncompressed radio signal
		"message" = message, 	// the actual sent message
		"radio" = src, 			// stores the radio used for transmission
		"slow" = 0,
		"traffic" = 0,
		"type" = 0,
		"server" = null,
		"reject" = 0,
		"level" = position.z,
		"language" = language,
		"spans" = spans,
		"verb_say" = M.verb_say,
		"verb_ask" = M.verb_ask,
		"verb_exclaim" = M.verb_exclaim,
		"verb_yell" = M.verb_yell
		)
	signal.frequency = freqnum // Quick frequency set
	for(var/obj/machinery/telecomms/receiver/R in GLOB.telecomms_list)
		R.receive_signal(signal)

	// Allinone can act as receivers. (Unless of course whoever coded this last time forgot to put it in somewhere!)
	for(var/obj/machinery/telecomms/allinone/R in GLOB.telecomms_list)
		R.receive_signal(signal)

	spawn(20) // wait a little...

		if(signal.data["done"] && position.z in signal.data["level"])
			// we're done here.
			return

		// Oh my god; the comms are down or something because the signal hasn't been broadcasted yet in our level.
		// Send a mundane broadcast with limited targets:
		Broadcast_Message(M, voicemask,
						  src, message, voice, jobname, real_name,
						  filter_type, signal.data["compression"], list(position.z), freq, spans,
						  verb_say, verb_ask, verb_exclaim, verb_yell, language)

/obj/item/device/radio/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(radio_freq)
		return
	if(broadcasting)
		if(get_dist(src, speaker) <= canhear_range)
			if(message_mode == MODE_WHISPER || message_mode == MODE_WHISPER_CRIT)
				raw_message = stars(raw_message)
			talk_into(speaker, raw_message, , spans, language=message_language)
/*
/obj/item/device/radio/proc/accept_rad(obj/item/device/radio/R as obj, message)

	if ((R.frequency == frequency && message))
		return 1
	else if

	else
		return null
	return
*/


/obj/item/device/radio/proc/receive_range(freq, level)
	// check if this radio can receive on the given frequency, and if so,
	// what the range is in which mobs will hear the radio
	// returns: -1 if can't receive, range otherwise

	if (wires.is_cut(WIRE_RX))
		return -1
	if(!listening)
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(!position || !(position.z in level))
			return -1
	if(freq == GLOB.SYND_FREQ)
		if(!(src.syndie)) //Checks to see if it's allowed on that frequency, based on the encryption keys
			return -1
	if(freq == GLOB.CENTCOM_FREQ)
		if(!independent)
			return -1
	if (!on)
		return -1
	if (!freq) //received on main frequency
		if (!listening)
			return -1
	else
		var/accept = (freq==frequency && listening)
		if (!accept)
			for(var/ch_name in channels)
				if(channels[ch_name] & FREQ_LISTENING)
					if(GLOB.radiochannels[ch_name] == text2num(freq) || syndie) //the GLOB.radiochannels list is located in communications.dm
						accept = 1
						break
		if (!accept)
			return -1
	return canhear_range

/obj/item/device/radio/proc/send_hear(freq, level)

	var/range = receive_range(freq, level)
	if(range > -1)
		return get_hearers_in_view(canhear_range, src)


/obj/item/device/radio/examine(mob/user)
	..()
	if (b_stat)
		to_chat(user, "<span class='notice'>[name] can be attached and modified.</span>")
	else
		to_chat(user, "<span class='notice'>[name] can not be modified or attached.</span>")

/obj/item/device/radio/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/screwdriver))
		b_stat = !b_stat
		if(b_stat)
			to_chat(user, "<span class='notice'>The radio can now be attached and modified!</span>")
		else
			to_chat(user, "<span class='notice'>The radio can no longer be modified or attached!</span>")
	else
		return ..()

/obj/item/device/radio/emp_act(severity)
	emped++ //There's been an EMP; better count it
	var/curremp = emped //Remember which EMP this was
	if (listening && ismob(loc))	// if the radio is turned on and on someone's person they notice
		to_chat(loc, "<span class='warning'>\The [src] overloads.</span>")
	broadcasting = 0
	listening = 0
	for (var/ch_name in channels)
		channels[ch_name] = 0
	on = FALSE
	spawn(200)
		if(emped == curremp) //Don't fix it if it's been EMP'd again
			emped = 0
			if (!istype(src, /obj/item/device/radio/intercom)) // intercoms will turn back on on their own
				on = TRUE
	..()

///////////////////////////////
//////////Borg Radios//////////
///////////////////////////////
//Giving borgs their own radio to have some more room to work with -Sieve

/obj/item/device/radio/borg
	name = "cyborg radio"
	subspace_switchable = 1
	dog_fashion = null
	flags_2 = NO_EMP_WIRES_2

/obj/item/device/radio/borg/Initialize(mapload)
	. = ..()

/obj/item/device/radio/borg/syndicate
	syndie = 1
	keyslot = new /obj/item/device/encryptionkey/syndicate

/obj/item/device/radio/borg/syndicate/Initialize()
	. = ..()
	set_frequency(GLOB.SYND_FREQ)

/obj/item/device/radio/borg/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/screwdriver))
		if(keyslot)
			for(var/ch_name in channels)
				SSradio.remove_object(src, GLOB.radiochannels[ch_name])
				secure_radio_connections[ch_name] = null


			if(keyslot)
				var/turf/T = get_turf(user)
				if(T)
					keyslot.loc = T
					keyslot = null

			recalculateChannels()
			to_chat(user, "<span class='notice'>You pop out the encryption key in the radio.</span>")

		else
			to_chat(user, "<span class='warning'>This radio doesn't have any encryption keys!</span>")

	else if(istype(W, /obj/item/device/encryptionkey/))
		if(keyslot)
			to_chat(user, "<span class='warning'>The radio can't hold another key!</span>")
			return

		if(!keyslot)
			if(!user.transferItemToLoc(W, src))
				return
			keyslot = W

		recalculateChannels()


/obj/item/device/radio/off	// Station bounced radios, their only difference is spawning with the speakers off, this was made to help the lag.
	listening = 0			// And it's nice to have a subtype too for future features.
	dog_fashion = /datum/dog_fashion/back
