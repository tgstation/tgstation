/mob/living/silicon/pai/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null)
	if(silent)
		to_chat(src, span_warning("Communication circuits remain uninitialized."))
	else
		..()

/mob/living/silicon/pai/binarycheck()
	return radio?.translate_binary
