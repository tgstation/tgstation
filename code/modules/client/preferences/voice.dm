/// TTS voice preference
/datum/preference/choiced/voice
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/voice/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled)
		return FALSE
	return ..()

/datum/preference/choiced/voice/init_possible_values()
	if(SStts.tts_enabled)
		return SStts.available_speakers
	if(fexists("data/cached_tts_voices.json"))
		var/list/text_data = rustg_file_read("data/cached_tts_voices.json")
		var/list/cached_data = json_decode(text_data)
		if(!cached_data)
			return list("invalid")
		return cached_data
	return list("invalid")

/datum/preference/choiced/voice/apply_to_human(mob/living/carbon/human/target, value)
	if(SStts.tts_enabled && !(value in SStts.available_speakers))
		value = pick(SStts.available_speakers) // As a failsafe
	target.voice = value

/datum/preference/numeric/tts_voice_pitch
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice_pitch"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	minimum = -12
	maximum = 12

/datum/preference/numeric/tts_voice_pitch/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled || !SStts.pitch_enabled)
		return FALSE
	return ..()

/datum/preference/numeric/tts_voice_pitch/create_default_value()
	return 0

/datum/preference/numeric/tts_voice_pitch/apply_to_human(mob/living/carbon/human/target, value)
	if(SStts.tts_enabled && SStts.pitch_enabled)
		target.pitch = value
