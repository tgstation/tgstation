/mob/living/carbon/monkey/say_quote(var/text)
	return "chimpers, [text]";

/mob/living/carbon/monkey/say_understands(var/mob/other,var/datum/language/speaking = null)
	if(other) other = other.GetSource()
	if(issilicon(other))
		return 1

	if(speaking && speaking.name == "Galactic Common")
		if(dexterity_check())
			return 1

	return ..()
