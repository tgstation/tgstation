/mob/living/carbon/slime/say(var/message)
	..()

/mob/living/carbon/slime/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "telepathically asks, [text]";
	else if (ending == "!")
		return "telepathically cries, [text]";

	return "telepathically chirps, [text]";

/mob/living/carbon/slime/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker && speech.speaker != src && !speech.frequency)
		var/atom/movable/speaker=speech.speaker
		if(speaker)
			speaker = speaker.GetSource()
		if(speaker in Friends)
			speech_buffer = list()
			speech_buffer += speech.name
			speech_buffer += lowertext(html_encode(rendered_speech))
	..()

/mob/living/carbon/slime/say_understands(var/other)
	if (istype(other, /mob/living/carbon/slime))
		return 1
	return ..()