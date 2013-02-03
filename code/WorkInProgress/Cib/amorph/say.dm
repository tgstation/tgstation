/mob/living/carbon/amorph/emote(var/act,var/m_type=1,var/message = null)
	if(act == "me")
		return custom_emote(m_type, message)

/mob/living/carbon/amorph/say_quote(var/text)
	return "[src.say_message], \"[text]\"";
