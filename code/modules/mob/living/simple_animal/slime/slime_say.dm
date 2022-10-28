/mob/living/simple_animal/slime/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list(), message_range)
	. = ..()
	if(speaker == src || radio_freq || stat || !(speaker in Friends))
		return

	speech_buffer = list()
	speech_buffer += speaker
	speech_buffer += lowertext(raw_message)
