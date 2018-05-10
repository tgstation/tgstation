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
	if(clothing.speech_modification == 1)
		message = speechModification(message)

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

/mob/living/carbon/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	if(!client)
		return
	for(var/T in get_traumas())
		var/datum/brain_trauma/trauma = T
		message = trauma.on_hear(message, speaker, message_language, raw_message, radio_freq)
	return ..()


/mob/living/carbon/LanguageMod
	var/obj/item/isEquipped = get_worn_item()		//Anything you're wearing can affect speech
		if(!isEqupped)									//If we're not wearing anything, don't waste time checking

			return message

		else

			if(isEquipped)

				message = item.speechModification(message)	//Modify speech from the items that are present and then return it.

	return message

	//Just moving this part into saycode for now, under construction don't look it's ugly

	if(copytext(M, 1, 2) != "*")
		M = " [M]"
		var/list/language_words = strings("lanugage_replacement.json", "language")

		for(var/key in words)
			var/value = language_words[key]
			if(islist(value))
				value = pick(value)

			M = replacetextEx(M, " [uppertext(key)]", " [uppertext(value)]")
			M = replacetextEx(M, " [capitalize(key)]", " [capitalize(value)]")
			M = replacetextEx(M, " [key]", " [value]")

	return trim(M)