/mob/living/carbon/treat_message(message)
	message = ..(message)
	if(wear_mask)
		message = wear_mask.speechModification(message)

	return message

/mob/living/carbon/can_speak_basic(message)
	if(silent)
		return 0
	return ..()
