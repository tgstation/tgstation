/mob/living/carbon/slime/say(var/message)
	..()

/mob/living/carbon/slime/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "telepathically asks, \"[text]\"";
	else if (ending == "!")
		return "telepathically cries, \"[text]\"";

	return "telepathically chirps, \"[text]\"";

/mob/living/carbon/slime/Hear(message, atom/movable/speaker, message_langs, raw_message, steps, radio_freq)
	if(speaker != src)
		if (speaker in Friends)
			speech_buffer = list()
			speech_buffer += speaker.name
			speech_buffer += lowertext(html_decode(message))
	..()
