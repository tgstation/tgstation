/mob/dead/observer/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_say("Ghost/[src.key] (@[src.x],[src.y],[src.z]): [message]")

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			src << "\red You cannot talk in deadchat (muted)."
			return

		if (src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	. = src.say_dead(message)

/mob/dead/observer/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "[pick("moans", "gripes", "grumps", "murmurs", "mumbles", "bleats")], \"[text]\"";
	else if (ending == "!")
		return "[pick("screams", "screeches", "howls")], \"[text]\"";

	return "[pick("whines", "cries", "spooks", "complains", "drones", "mutters")], \"[text]\"";

/mob/dead/observer/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
	if(radio_freq)
		speaker = speaker.GetSource()
	var/turf/T = get_turf(speaker)
	if(get_dist(T, src) <= world.view) // if this isn't true, we can't be in view, so no need for costlier proc
		if(T in view(src))
			message = "<b>[message]</b>"
	src << "<a href='?src=\ref[src];follow=\ref[speaker]'>(Follow)</a> [message]"
