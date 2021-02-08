/mob/dead/observer/check_emote(message, forced)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = !forced)
		return TRUE


//Modified version of get_message_mods, removes the trimming, the only thing we care about here is admin channels
/mob/dead/observer/get_message_mods(message, list/mods)
	var/key = message[1]
	if((key in GLOB.department_radio_prefixes) && length(message) > length(key) + 1 && !mods[RADIO_EXTENSION])
		mods[RADIO_KEY] = lowertext(message[1 + length(key)])
		mods[RADIO_EXTENSION] = GLOB.department_radio_keys[mods[RADIO_KEY]]
	return message

/mob/dead/observer/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if (!message)
		return
	var/list/message_mods = list()
	message = get_message_mods(message, message_mods)
	if(client && (message_mods[RADIO_EXTENSION] == MODE_ADMIN || message_mods[RADIO_EXTENSION] == MODE_DEADMIN))
		message = trim_left(copytext_char(message, length(message_mods[RADIO_KEY]) + 2))
		if(message_mods[RADIO_EXTENSION] == MODE_ADMIN)
			client.cmd_admin_say(message)
		else if(message_mods[RADIO_EXTENSION] == MODE_DEADMIN)
			client.dsay(message)
		return

	if(check_emote(message, forced))
		return

	. = say_dead(message)

/mob/dead/observer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	var/atom/movable/to_follow = speaker
	if(radio_freq)
		var/atom/movable/virtualspeaker/V = speaker

		if(isAI(V.source))
			var/mob/living/silicon/ai/S = V.source
			to_follow = S.eyeobj
		else
			to_follow = V.source
	var/link = FOLLOW_LINK(src, to_follow)
	// Create map text prior to modifying message for goonchat
	if (client?.prefs.chat_on_map && (client.prefs.see_chat_non_mob || ismob(speaker)))
		create_chat_message(speaker, message_language, raw_message, spans)
	// Recompose the message, because it's scrambled by default
	message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)
	to_chat(src,
		html = "[link] [message]",
		avoid_highlighting = speaker == src)

