/// TTS voice preference
/datum/preference/choiced/voice
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice"
	priority = PREFERENCE_PRIORITY_VOICE
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/voice/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled)
		return FALSE
	return ..()

/datum/preference/choiced/voice/init_possible_values()
	if(SStts.tts_enabled)
		return SStts.available_speakers
	if(fexists("data/cached_tts_voices.json"))
		var/list/text_data = ""
		// Can't use rustg to read the file here because this can run before auxtools has time to even load.
		READ_FILE(file("data/cached_tts_voices.json"), text_data)
		var/list/cached_data = json_decode(text_data)
		return cached_data
	return list("invalid")

/datum/preference/choiced/voice/apply_to_human(mob/living/carbon/human/target, value)
	target.voice = value
