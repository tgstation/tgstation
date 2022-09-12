/mob/living/proc/robot_talk(message)
	log_talk(message, LOG_SAY, tag="binary")

	var/designation = "Default Cyborg"
	var/message_class = ""

	if(issilicon(src))
		var/mob/living/silicon/player = src
		designation = trim_left(player.designation + " " + player.job)

	if(isAI(src))
		// AIs are loud and ugly
		message_class = "binarysay--aisay"

	var/quoted_message = say_quote(
		message,
		spans=list(message_class)
	)

	for(var/mob/M in GLOB.player_list)
		if(M.binarycheck())
			if(isAI(M))
				to_chat(
					M,
					span_binarysay("\
						Robotic Talk, \
						<a href='?src=[REF(M)];track=[html_encode(name)]'>[span_name("[name] ([designation])")]</a> \
						<span class='message'>[quoted_message]</span>\
					"),
					avoid_highlighting = src == M
				)
			else
				to_chat(
					M,
					span_binarysay("\
						Robotic Talk, \
						[span_name("[name]")] <span class='message'>[quoted_message]</span>\
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

			to_chat(
				M,
				FOLLOW_LINK(M, following) + span_binarysay(" \
					Robotic Talk, \
					[span_name("[name]")] <span class='message'>[quoted_message]</span>\
				"),
				avoid_highlighting = src == M
			)

/mob/living/silicon/binarycheck()
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
