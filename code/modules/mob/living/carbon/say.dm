/mob/living/carbon/proc/handle_tongueless_speech(mob/living/carbon/speaker, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/static/regex/tongueless_lower = new("\[gdntke]+", "g")
	var/static/regex/tongueless_upper = new("\[GDNTKE]+", "g")
	if(message[1] != "*")
		message = tongueless_lower.Replace(message, pick("aa","oo","'"))
		message = tongueless_upper.Replace(message, pick("AA","OO","'"))
		speech_args[SPEECH_MESSAGE] = message

/mob/living/carbon/can_speak_vocal(message)
	if(silent)
		return 0
	return ..()

/mob/living/carbon/could_speak_in_language(datum/language/dt)
	var/obj/item/organ/tongue/T = getorganslot(ORGAN_SLOT_TONGUE)
	if(T)
		. = T.could_speak_in_language(dt)
	else
		. = initial(dt.flags) & TONGUELESS_SPEECH

/mob/living/carbon/hear_intercept(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	var/datum/status_effect/bugged/B = has_status_effect(STATUS_EFFECT_BUGGED)
	if(B)
		B.listening_in.show_message(message)
	for(var/T in get_traumas())
		var/datum/brain_trauma/trauma = T
		message = trauma.on_hear(message, speaker, message_language, raw_message, radio_freq)

	if (src.mind.has_antag_datum(/datum/antagonist/traitor))
		message = GLOB.syndicate_code_phrase_regex.Replace(message, "<span class='blue'>$1</span>")
		message = GLOB.syndicate_code_response_regex.Replace(message, "<span class='red'>$1</span>")

	return message
