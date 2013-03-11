/mob/living/carbon/monkey/say(var/message)
	if (silent)
		return
	else
		return ..()

/mob/living/carbon/monkey/say_quote(var/text)
	return "[src.say_message], \"[text]\"";
