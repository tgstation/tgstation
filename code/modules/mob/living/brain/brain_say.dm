/mob/living/brain/say(
	message,
	bubble_type,
	list/spans = list(),
	sanitize = TRUE,
	datum/language/language,
	ignore_spam = FALSE,
	forced,
	filterproof = FALSE,
	message_range = 7,
	datum/saymode/saymode,
	list/message_mods = list(),
)
	if(prob(emp_damage * 4))
		if(prob(10)) //10% chance to drop the message entirely
			return
		message = Gibberish(message, emp_damage >= 12)//scrambles the message, gets worse when emp_damage is higher

	return ..()

/mob/living/brain/can_speak(allow_mimes)
	return istype(container, /obj/item/mmi) && ..()

/mob/living/brain/radio(message, list/message_mods = list(), list/spans, language)
	if(message_mods[MODE_HEADSET] && istype(container, /obj/item/mmi))
		var/obj/item/mmi/R = container
		if(R.radio)
			R.radio.talk_into(src, message, language = language, message_mods = message_mods)
			return ITALICS | REDUCE_RANGE
	else
		return ..()

/mob/living/brain/treat_message(message, tts_message, tts_filter, capitalize_message = TRUE)
	if(capitalize_message)
		message = capitalize(message)
	return list(message = message, tts_message = message, tts_filter = list())
