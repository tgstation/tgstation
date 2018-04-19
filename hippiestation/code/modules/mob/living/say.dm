/mob/living/can_speak_vocal(message)
	if(has_trait(TRAIT_MUTE))
		return FALSE

	if(is_muzzled())
		return FALSE

	if(!IsVocal())
		return FALSE

	if(pulledby && pulledby.grab_state == GRAB_KILL)
		return FALSE

	return TRUE

/mob/living/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE)
	// If we're in soft crit and tried to talk, automatically make us whisper
	if (length(message) > 2)
		var/first_char = copytext(message, 1, 2)

		if (first_char != "*" && stat == SOFT_CRIT && get_message_mode(message) != MODE_WHISPER)
			message = "#" + message

	. = ..()