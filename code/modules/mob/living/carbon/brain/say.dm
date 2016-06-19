/mob/living/carbon/brain/say(var/message)

	if(!(container && (istype(container, /obj/item/device/mmi))))
		return say_dead(message) // he's dead. Let him speak to the dead.
	else
		if(prob(emp_damage*4))
			if(prob(10))
				return
			else
				message = Gibberish(message, (emp_damage*6)) //scrambles the message, gets worse when emp_damage is higher
	return ..(message)

/mob/living/carbon/brain/radio(var/datum/speech/speech, var/message_mode)
	if(message_mode && istype(container, /obj/item/device/mmi/radio_enabled))
		var/obj/item/device/mmi/radio_enabled/R = container
		if(R.radio)
			R.radio.talk_into(speech) // Might need message_mode
			return ITALICS | REDUCE_RANGE

/mob/living/carbon/brain/lingcheck()
	return 0

/mob/living/carbon/brain/treat_speech(var/datum/speech/speech, genesay = 0)
	..(speech)
	if(container && istype(container, /obj/item/device/mmi/posibrain))
		speech.message_classes.Add("siliconsay")

/mob/living/carbon/brain/say_quote(var/text)
	if(container && istype(container, /obj/item/device/mmi/posibrain))
		var/ending = copytext(text, length(text))

		if (ending == "?")
			return "queries, [text]";
		else if (ending == "!")
			return "declares, [text]";
		return "states, [text]";

	else
		return ..()