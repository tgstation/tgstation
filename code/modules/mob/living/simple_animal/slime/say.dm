/mob/living/simple_animal/slime/Hear(datum/spoken_info/info)
	. = ..()
	if(info.source != src && !info.radio_freq && !stat)
		if (info.source in Friends)
			speech_buffer = list()
			speech_buffer += info.source
			speech_buffer += lowertext(html_decode(info.getMsg()))
