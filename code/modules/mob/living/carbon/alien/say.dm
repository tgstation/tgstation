/mob/living/carbon/alien/say_understands(var/other)
	if (istype(other, /mob/living/carbon/alien))
		return 1
	return ..()


// ~lol~
/mob/living/carbon/alien/say_quote(var/text)
//	var/ending = copytext(text, length(text))

	return "hisses, \"[text]\"";
