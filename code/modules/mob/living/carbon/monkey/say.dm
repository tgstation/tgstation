/mob/living/carbon/monkey/say_quote(var/text)
	return "chimpers, \"[text]\"";

/mob/living/carbon/monkey/say_understands(var/mob/other,var/datum/language/speaking = null)

	if(issilicon(other))
		return 1
	return ..()