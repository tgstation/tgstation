/mob/dead/observer/say(message)
	message = strip_html_properly(trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)))

	if (!message)
		return

	log_say("Ghost/[src.key] : [message]")

	. = src.say_dead(message)

/mob/dead/observer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	var/atom/movable/to_follow = speaker
	if(radio_freq)
		var/atom/movable/virtualspeaker/V = speaker

		if(isAI(V.source))
			var/mob/living/silicon/ai/S = V.source
			to_follow = S.eyeobj
		else
			to_follow = V.source
	var/link = FOLLOW_LINK(src, to_follow)
	// Recompose the message, because it's scrambled by default
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode)
	to_chat(src, "[link] [message]")

