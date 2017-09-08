GLOBAL_LIST_INIT(department_radio_prefixes, list(":", "."))

GLOBAL_LIST_INIT(department_radio_keys, list(
	// Location
	"r" = "right hand",
	"l" = "left hand",
	"i" = "intercom",

	// Department
	"h" = "department",
	"c" = "Command",
	"n" = "Science",
	"m" = "Medical",
	"e" = "Engineering",
	"s" = "Security",
	"u" = "Supply",
	"v" = "Service",

	// Faction
	"t" = "Syndicate",
	"y" = "CentCom",

	// Species
	"b" = "binary",
	"g" = "changeling",
	"a" = "alientalk",

	// Admin
	"p" = "admin",
	"d" = "deadmin",

	// Misc
	"o" = "AI Private", // AI Upload channel
	"x" = "cords",		// vocal cords, used by Voice of God


	//kinda localization -- rastaf0
	//same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	// Location
	"ê" = "right hand",
	"ä" = "left hand",
	"ø" = "intercom",

	// Department
	"ð" = "department",
	"ñ" = "Command",
	"ò" = "Science",
	"ü" = "Medical",
	"ó" = "Engineering",
	"û" = "Security",
	"ã" = "Supply",
	"ì" = "Service",

	// Faction
	"å" = "Syndicate",
	"í" = "CentCom",

	// Species
	"è" = "binary",
	"ï" = "changeling",
	"ô" = "alientalk",

	// Admin
	"ç" = "admin",
	"â" = "deadmin",

	// Misc
	"ù" = "AI Private",
	"÷" = "cords"
))

/mob/living/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null)
	var/static/list/crit_allowed_modes = list(MODE_WHISPER = TRUE, MODE_CHANGELING = TRUE, MODE_ALIEN = TRUE)
	var/static/list/unconscious_allowed_modes = list(MODE_CHANGELING = TRUE, MODE_ALIEN = TRUE)

	var/static/list/one_character_prefix = list(MODE_HEADSET = TRUE, MODE_ROBOT = TRUE, MODE_WHISPER = TRUE)

	if(sanitize)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return

	var/message_mode = get_message_mode(message)
	var/original_message = message
	var/in_critical = InCritical()

	if(one_character_prefix[message_mode])
		message = copytext(message, 2)
	else if(message_mode)
		message = copytext(message, 3)
	if(findtext(message, " ", 1, 2))
		message = copytext(message, 2)

	if(message_mode == "admin")
		if(client)
			client.cmd_admin_say(message)
		return

	if(message_mode == "deadmin")
		if(client)
			client.dsay(message)
		return

	if(stat == DEAD)
		say_dead(original_message)
		return

	if(check_emote(original_message) || !can_speak_basic(original_message))
		return

	if(in_critical)
		if(!(crit_allowed_modes[message_mode]))
			return
	else if(stat == UNCONSCIOUS)
		if(!(unconscious_allowed_modes[message_mode]))
			return

	// language comma detection.
	var/datum/language/message_language = get_message_language(message)
	if(message_language)
		// No, you cannot speak in xenocommon just because you know the key
		if(can_speak_in_language(message_language))
			language = message_language
		message = copytext(message, 3)

		// Trim the space if they said ",0 I LOVE LANGUAGES"
		if(findtext(message, " ", 1, 2))
			message = copytext(message, 2)

	if(!language)
		language = get_default_language()

	// Detection of language needs to be before inherent channels, because
	// AIs use inherent channels for the holopad. Most inherent channels
	// ignore the language argument however.

	if(handle_inherent_channels(message, message_mode, language)) //Hiveminds, binary chat & holopad.
		return

	if(!can_speak_vocal(message))
		to_chat(src, "<span class='warning'>You find yourself unable to speak!</span>")
		return

	var/message_range = 7

	var/succumbed = FALSE

	var/fullcrit = InFullCritical()
	if((InCritical() && !fullcrit) || message_mode == MODE_WHISPER)
		message_range = 1
		message_mode = MODE_WHISPER
		log_talk(src,"[key_name(src)] : [message]",LOGWHISPER)
		if(fullcrit)
			var/health_diff = round(-HEALTH_THRESHOLD_DEAD + health)
			// If we cut our message short, abruptly end it with a-..
			var/message_len = length(message)
			message = copytext(message, 1, health_diff) + "[message_len > health_diff ? "-.." : "..."]"
			message = Ellipsis(message, 10, 1)
			last_words = message
			message_mode = MODE_WHISPER_CRIT
			succumbed = TRUE
	else
		log_talk(src,"[name]/[key] : [message]",LOGSAY)

	message = treat_message(message)
	if(!message)
		return

	spans |= get_spans()

	if(language)
		var/datum/language/L = GLOB.language_datum_instances[language]
		spans |= L.spans

	//Log what we've said with an associated timestamp, using the list's len for safety/to prevent overwriting messages
	log_message(message, INDIVIDUAL_SAY_LOG)

	var/radio_return = radio(message, message_mode, spans, language)
	if(radio_return & ITALICS)
		spans |= SPAN_ITALICS
	if(radio_return & REDUCE_RANGE)
		message_range = 1

	//No screams in space, unless you're next to someone.
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = (environment)? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE)
		message_range = 1

	if(pressure < ONE_ATMOSPHERE*0.4) //Thin air, let's italicise the message
		spans |= SPAN_ITALICS

	send_speech(message, message_range, src, bubble_type, spans, language, message_mode)

	if(succumbed)
		succumb(1)
		to_chat(src, compose_message(src, language, message, , spans, message_mode))

	return 1

/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	if(!client)
		return
	var/deaf_message
	var/deaf_type
	if(speaker != src)
		if(!radio_freq) //These checks have to be seperate, else people talking on the radio will make "You can't hear yourself!" appear when hearing people over the radio while deaf.
			deaf_message = "<span class='name'>[speaker]</span> [speaker.verb_say] something but you cannot hear them."
			deaf_type = 1
	else
		deaf_message = "<span class='notice'>You can't hear yourself!</span>"
		deaf_type = 2 // Since you should be able to hear yourself without looking

	// Recompose message for AI hrefs, language incomprehension.
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode)
	show_message(message, 2, deaf_message, deaf_type)
	return message

/mob/living/send_speech(message, message_range = 6, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, message_mode)
	var/static/list/eavesdropping_modes = list(MODE_WHISPER = TRUE, MODE_WHISPER_CRIT = TRUE)
	var/eavesdrop_range = 0
	if(eavesdropping_modes[message_mode])
		eavesdrop_range = EAVESDROP_EXTRA_RANGE
	var/list/listening = get_hearers_in_view(message_range+eavesdrop_range, source)
	var/list/the_dead = list()
	for(var/_M in GLOB.player_list)
		var/mob/M = _M
		if(M.stat != DEAD) //not dead, not important
			continue
		if(!M.client || !client) //client is so that ghosts don't have to listen to mice
			continue
		if(get_dist(M, src) > 7 || M.z != z) //they're out of range of normal hearing
			if(eavesdropping_modes[message_mode] && !(M.client.prefs.chat_toggles & CHAT_GHOSTWHISPER)) //they're whispering and we have hearing whispers at any range off
				continue
			if(!(M.client.prefs.chat_toggles & CHAT_GHOSTEARS)) //they're talking normally and we have hearing at any range off
				continue
		listening |= M
		the_dead[M] = TRUE

	var/eavesdropping
	var/eavesrendered
	if(eavesdrop_range)
		eavesdropping = stars(message)
		eavesrendered = compose_message(src, message_language, eavesdropping, , spans, message_mode)

	var/rendered = compose_message(src, message_language, message, , spans, message_mode)
	for(var/_AM in listening)
		var/atom/movable/AM = _AM
		if(eavesdrop_range && get_dist(source, AM) > message_range && !(the_dead[AM]))
			AM.Hear(eavesrendered, src, message_language, eavesdropping, , spans, message_mode)
		else
			AM.Hear(rendered, src, message_language, message, , spans, message_mode)

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	var/image/I = image('icons/mob/talk.dmi', src, "[bubble_type][say_test(message)]", FLY_LAYER)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, /.proc/flick_overlay, I, speech_bubble_recipients, 30)

/mob/proc/binarycheck()
	return 0

/mob/living/can_speak(message) //For use outside of Say()
	if(can_speak_basic(message) && can_speak_vocal(message))
		return 1

/mob/living/proc/can_speak_basic(message) //Check BEFORE handling of xeno and ling channels
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
			return 0
		if(client.handle_spam_prevention(message,MUTE_IC))
			return 0

	return 1

/mob/living/proc/can_speak_vocal(message) //Check AFTER handling of xeno and ling channels
	if(disabilities & MUTE)
		return 0

	if(is_muzzled())
		return 0

	if(!IsVocal())
		return 0

	return 1

/mob/living/proc/check_emote(message)
	if(copytext(message, 1, 2) == "*")
		emote(copytext(message, 2))
		return 1

/mob/living/proc/get_message_mode(message)
	var/key = copytext(message, 1, 2)
	if(key == "#")
		return MODE_WHISPER
	else if(key == ";")
		return MODE_HEADSET
	else if(length(message) > 2 && (key in GLOB.department_radio_prefixes))
		var/key_symbol = lowertext(copytext(message, 2, 3))
		return GLOB.department_radio_keys[key_symbol]

/mob/living/proc/get_message_language(message)
	if(copytext(message, 1, 2) == ",")
		var/key = copytext(message, 2, 3)
		for(var/ld in GLOB.all_languages)
			var/datum/language/LD = ld
			if(initial(LD.key) == key)
				return LD
	return null

/mob/living/proc/handle_inherent_channels(message, message_mode)
	if(message_mode == MODE_CHANGELING)
		switch(lingcheck())
			if(3)
				var/msg = "<i><font color=#800040><b>[src.mind]:</b> [message]</font></i>"
				for(var/_M in GLOB.mob_list)
					var/mob/M = _M
					if(M in GLOB.dead_mob_list)
						var/link = FOLLOW_LINK(M, src)
						to_chat(M, "[link] [msg]")
					else
						switch(M.lingcheck())
							if(3)
								to_chat(M, msg)
							if(2)
								to_chat(M, msg)
							if(1)
								if(prob(40))
									to_chat(M, "<i><font color=#800080>We can faintly sense an outsider trying to communicate through the hivemind...</font></i>")
			if(2)
				var/msg = "<i><font color=#800080><b>[mind.changeling.changelingID]:</b> [message]</font></i>"
				log_talk(src,"[mind.changeling.changelingID]/[key] : [message]",LOGSAY)
				for(var/_M in GLOB.mob_list)
					var/mob/M = _M
					if(M in GLOB.dead_mob_list)
						var/link = FOLLOW_LINK(M, src)
						to_chat(M, "[link] [msg]")
					else
						switch(M.lingcheck())
							if(3)
								to_chat(M, msg)
							if(2)
								to_chat(M, msg)
							if(1)
								if(prob(40))
									to_chat(M, "<i><font color=#800080>We can faintly sense another of our kind trying to communicate through the hivemind...</font></i>")
			if(1)
				to_chat(src, "<i><font color=#800080>Our senses have not evolved enough to be able to communicate this way...</font></i>")
		return TRUE
	if(message_mode == MODE_ALIEN)
		if(hivecheck())
			alien_talk(message)
		return TRUE
	if(message_mode == MODE_VOCALCORDS)
		if(iscarbon(src))
			var/mob/living/carbon/C = src
			var/obj/item/organ/vocal_cords/V = C.getorganslot("vocal_cords")
			if(V && V.can_speak_with())
				V.handle_speech(message) //message
				V.speak_with(message) //action
		return TRUE
	return FALSE

/mob/living/proc/treat_message(message)
	if(getBrainLoss() >= 60)
		message = derpspeech(message, stuttering)

	if(stuttering)
		message = stutter(message)

	if(slurring)
		message = slur(message)

	if(cultslurring)
		message = cultslur(message)

	message = capitalize(message)

	return message

/mob/living/proc/radio(message, message_mode, list/spans, language)
	switch(message_mode)
		if(MODE_WHISPER)
			return ITALICS
		if(MODE_R_HAND)
			for(var/obj/item/r_hand in get_held_items_for_side("r", all = TRUE))
				if (r_hand)
					return r_hand.talk_into(src, message, , spans, language)
				return ITALICS | REDUCE_RANGE
		if(MODE_L_HAND)
			for(var/obj/item/l_hand in get_held_items_for_side("l", all = TRUE))
				if (l_hand)
					return l_hand.talk_into(src, message, , spans, language)
				return ITALICS | REDUCE_RANGE

		if(MODE_INTERCOM)
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message, , spans, language)
			return ITALICS | REDUCE_RANGE

		if(MODE_BINARY)
			if(binarycheck())
				robot_talk(message)
			return ITALICS | REDUCE_RANGE //Does not return 0 since this is only reached by humans, not borgs or AIs.
	return 0

/mob/living/lingcheck() //1 is ling w/ no hivemind. 2 is ling w/hivemind. 3 is ling victim being linked into hivemind.
	if(mind && mind.changeling)
		if(mind.changeling.changeling_speak)
			return 2
		return 1
	if(mind && mind.linglink)
		return 3
	return 0

/mob/living/say_mod(input, message_mode)
	if(message_mode == MODE_WHISPER)
		. = verb_whisper
	else if(message_mode == MODE_WHISPER_CRIT)
		. = "[verb_whisper] in [p_their()] last breath"
	else if(stuttering)
		. = "stammers"
	else if(getBrainLoss() >= 60)
		. = "gibbers"
	else
		. = ..()

/mob/living/whisper(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null)
	say("#[message]", bubble_type, spans, sanitize, language)

/mob/living/get_language_holder(shadow=TRUE)
	if(mind && shadow)
		// Mind language holders shadow mob holders.
		. = mind.get_language_holder()
		if(.)
			return .

	. = ..()
