/mob/living
	var/use_accent = TRUE

/// Overload the speech-handling verb to seamlessly disable all tongue replacements. Magic!
/obj/item/organ/tongue/should_modify_speech(datum/source, list/speech_args)
	if (owner.use_accent)
		return ..()

	return FALSE

/mob/living/verb/accent_toggle_verb()
	set name = "Toggle Speech Accent"
	set category = "IC"
	set instant = TRUE

	if (use_accent)
		use_accent = FALSE
		to_chat(src, span_notice("You will no longer automatically apply speech accents."))
	else
		use_accent = TRUE
		to_chat(src, span_notice("You will now automatically apply speech accents."))
