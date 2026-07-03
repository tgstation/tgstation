

/mob/living/carbon/human/say(
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
	if(!HAS_TRAIT(src, TRAIT_SPEAKS_CLEARLY))
		var/static/regex/tongueless_lower = new("\[gdntke]+", "g")
		var/static/regex/tongueless_upper = new("\[GDNTKE]+", "g")
		if(message[1] != "*")
			message = tongueless_lower.Replace(message, pick("aa","oo","'"))
			message = tongueless_upper.Replace(message, pick("AA","OO","'"))
	return ..()

/mob/living/carbon/human/get_default_say_verb()
	var/obj/item/organ/tongue/tongue = get_organ_slot(ORGAN_SLOT_TONGUE)
	if(isnull(tongue))
		if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
			return "signs"
		return "gurgles"
	return  ru_say_verb(tongue.temp_say_mod) || ru_say_verb(tongue.say_mod) || ..()

/mob/living/carbon/human/get_voice(add_id_name = FALSE)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN_VOICE))
		return "Unknown"
	var/id_name = get_id_name("")
	if(HAS_TRAIT(src, TRAIT_VOICE_MATCHES_ID) && id_name)
		return id_name
	if(override_voice)
		return override_voice
	if(add_id_name && real_name == id_name) // Allows for "Captain John" to have the voice "Captain Join" and not "John"
		return get_id_name("", honorifics = TRUE)
	return real_name

/mob/living/carbon/human/get_message_voice(visible_name)
	. = ..()
	if(. != name)
		. += " (as [get_id_name("Unknown", honorifics = TRUE)])"

/mob/living/carbon/human/binarycheck()
	if(stat >= SOFT_CRIT)
		return FALSE
	var/area/our_area = get_area(src)
	if(our_area.area_flags & BINARY_JAMMING)
		return FALSE
	var/obj/item/organ/brain/cybernetic/ai/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(istype(brain))
		return TRUE
	var/obj/item/radio/headset/dongle = ears
	if(!istype(dongle))
		return FALSE
	return dongle.special_channels & RADIO_SPECIAL_BINARY

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
	else if(GLOB.default_radio_channels[message_mods[RADIO_EXTENSION]])
		if(ears)
			ears.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return ITALICS | REDUCE_RANGE

	return FALSE
