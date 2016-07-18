/mob/dead/observer/say(message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	log_say("Ghost/[src.key] : [message]")

	if(jobban_isbanned(src, "OOC"))
		src << "<span class='danger'>You have been banned from deadchat.</span>"
		return

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			src << "<span class='danger'>You cannot talk in deadchat (muted).</span>"
			return

		if (src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	. = src.say_dead(message)

/mob/dead/observer/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(radio_freq)
		var/atom/movable/virtualspeaker/V = speaker

		if(istype(V.source, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/S = V.source
			speaker = S.eyeobj
		else
			speaker = V.source
	var/link = FOLLOW_LINK(src, speaker)
	src << "[link] [message]"

