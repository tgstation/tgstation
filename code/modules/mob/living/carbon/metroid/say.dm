/mob/living/carbon/metroid/say(var/message)
	if (silent)
		return
	else
		return ..()

/mob/living/carbon/metroid/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "telepathically asks, \"[text]\"";
	else if (ending == "!")
		return "telepathically cries, \"[text]\"";

	return "telepathically chirps, \"[text]\"";

/mob/living/carbon/metroid/say_understands(var/other)
	if (istype(other, /mob/living/carbon/metroid))
		return 1
	return ..()

