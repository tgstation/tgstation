/mob/living/simple_animal/slime/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list())
	. = ..()
	if(speaker != src && !radio_freq && !stat)
		if (speaker in Friends)
			speech_buffer = list()
			speech_buffer += speaker
			speech_buffer += lowertext(html_decode(message))
