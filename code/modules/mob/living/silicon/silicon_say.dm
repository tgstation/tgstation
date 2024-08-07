/mob/living/proc/robot_talk(message)
	log_talk(message, LOG_SAY, tag="binary")

	var/designation = "Default Cyborg"
	var/spans = list(SPAN_ROBOT)

	if(issilicon(src))
		var/mob/living/silicon/player = src
		designation = trim_left(player.designation + " " + player.job)

	if(HAS_TRAIT(mind, TRAIT_DISPLAY_JOB_IN_BINARY))
		designation = mind.assigned_role.title

	if(isAI(src))
		// AIs are loud and ugly
		spans |= SPAN_COMMAND

	var/quoted_message = say_quote(
		message,
		spans
	)

	var/namepart = name
	// If carbon, use voice to account for voice changers
	if(iscarbon(src))
		namepart = GetVoice()

	for(var/mob/M in GLOB.player_list)
		if(M.binarycheck())
			if(isAI(M))
				to_chat(
					M,
					span_binarysay("\
						Robotic Talk, \
						<a href='?src=[REF(M)];track=[html_encode(namepart)]'>[span_name("[namepart] ([designation])")]</a> \
						<span class='message'>[quoted_message]</span>\
					"),
					avoid_highlighting = src == M
				)
			else
				to_chat(
					M,
					span_binarysay("\
						Robotic Talk, \
						[span_name("[namepart]")] <span class='message'>[quoted_message]</span>\
					"),
					avoid_highlighting = src == M
				)

		if(isobserver(M))
			var/following = src

			// If the AI talks on binary chat, we still want to follow
			// its camera eye, like if it talked on the radio

			if(isAI(src))
				var/mob/living/silicon/ai/ai = src
				following = ai.eyeobj

			var/follow_link = FOLLOW_LINK(M, following)

			to_chat(
				M,
				span_binarysay("\
					[follow_link] \
					Robotic Talk, \
					[span_name("[namepart]")] <span class='message'>[quoted_message]</span>\
				"),
				avoid_highlighting = src == M
			)

/mob/living/silicon/binarycheck()
	var/area/our_area = get_area(src)
	if(our_area.area_flags & BINARY_JAMMING)
		return FALSE
	return TRUE

/mob/living/silicon/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(.)
		return
	if(message_mods[MODE_HEADSET])
		if(radio)
			radio.talk_into(src, message, , spans, language, message_mods)
		return REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] in GLOB.radiochannels)
		if(radio)
			radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return FALSE
