/mob/proc/use_that_empty_hand() //currently unused proc so i can implement 2-handing any item a lot easier in the future.
	return

/mob/say_mod(input, message_mode)
	var/customsayverb = findtext(input, "*")
	if(customsayverb)
		return lowertext(copytext(input, 1, customsayverb))
	. = ..()

/atom/movable/proc/attach_spans(input, list/spans)
	var/customsayverb = findtext(input, "*")
	if(customsayverb)
		input = capitalize(copytext(input, customsayverb+1))
	if(input)
		return "[message_spans_start(spans)][input]</span>"
	else
		return

/mob/living/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode, face_name = FALSE)
	. = ..()
	if(istype(speaker, /mob/living))
		var/turf/speakturf = get_turf(speaker)
		var/turf/sourceturf = get_turf(src)
		if(istype(speakturf) && istype(sourceturf) && !(speakturf in get_hear(5, sourceturf)))
			. = "<citspan class='small'>[.]</citspan>" //Don't ask how the fuck this works. It just does.
