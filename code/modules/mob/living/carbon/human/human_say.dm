

/mob/living/carbon/human/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode)
	if(!HAS_TRAIT(src, TRAIT_SPEAKS_CLEARLY))
		var/static/regex/tongueless_lower = new("\[gdntke]+", "g")
		var/static/regex/tongueless_upper = new("\[GDNTKE]+", "g")
		if(message[1] != "*")
			message = tongueless_lower.Replace(message, pick("aa","oo","'"))
			message = tongueless_upper.Replace(message, pick("AA","OO","'"))
	return ..()

/mob/living/carbon/human/say_mod(input, list/message_mods = list())
	var/obj/item/organ/internal/tongue/tongue = getorganslot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
			verb_say = "signs"
		else
			verb_say = "gurgles"
	else
		verb_say = tongue.temp_say_mod || tongue.say_mod
	return ..()

/mob/living/carbon/human/GetVoice()
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		return ("Unknown")

	if(istype(wear_mask, /obj/item/clothing/mask/chameleon))
		var/obj/item/clothing/mask/chameleon/V = wear_mask
		if(V.voice_change && wear_id)
			var/obj/item/card/id/idcard = wear_id.GetID()
			if(istype(idcard))
				return idcard.registered_name
			else
				return real_name
		else
			return real_name

	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling?.mimicing)
			return changeling.mimicing
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/proc/SetSpecialVoice(new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice

/mob/living/carbon/human/binarycheck()
	if(stat >= SOFT_CRIT || !ears)
		return FALSE
	var/obj/item/radio/headset/dongle = ears
	if(!istype(dongle))
		return FALSE
	return dongle.translate_binary

/mob/living/carbon/human/radio(message, list/message_mods = list(), list/spans, language) //Poly has a copy of this, lazy bastard
	. = ..()
	if(.)
		return

	if(message_mods[MODE_HEADSET])
		if(ears)
			ears.talk_into(src, message, , spans, language, message_mods)
		return ITALICS | REDUCE_RANGE
	else if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT)
		if(ears)
			ears.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
		return ITALICS | REDUCE_RANGE
	else if(GLOB.radiochannels[message_mods[RADIO_EXTENSION]])
		if(ears)
			ears.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return FALSE

/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"
