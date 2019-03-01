/mob/living/carbon/treat_message(message)
	for(var/datum/brain_trauma/trauma in get_traumas())
		message = trauma.on_say(message)
	message = ..(message)
	var/obj/item/organ/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	if(!T) //hoooooouaah!
		var/regex/tongueless_lower = new("\[gdntke]+", "g")
		var/regex/tongueless_upper = new("\[GDNTKE]+", "g")
		if(copytext(message, 1, 2) != "*")
			message = tongueless_lower.Replace(message, pick("aa","oo","'"))
			message = tongueless_upper.Replace(message, pick("AA","OO","'"))
	else
		message = T.TongueSpeech(message)
	if(wear_mask)
		message = wear_mask.speechModification(message)
	if(head)
		message = head.speechModification(message)
	return message

/mob/living/carbon/can_speak_vocal(message)
	if(silent)
		return 0
	return ..()

/mob/living/carbon/get_spans()
	. = ..()
	var/obj/item/organ/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	if(T)
		. |= T.get_spans()

	var/obj/item/I = get_active_held_item()
	if(I)
		. |= I.get_held_item_speechspans(src)

/mob/living/carbon/could_speak_in_language(datum/language/dt)
	var/obj/item/organ/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	if(T)
		. = T.could_speak_in_language(dt)
	else
		. = initial(dt.flags) & TONGUELESS_SPEECH

/mob/living/carbon/hear_intercept(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	for(var/T in get_traumas())
		var/datum/brain_trauma/trauma = T
		message = trauma.on_hear(message, speaker, message_language, raw_message, radio_freq)
	return message
