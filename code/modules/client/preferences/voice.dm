/// TTS voice preference
/datum/preference/choiced/voice
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_voice"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	should_update_preview = FALSE

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
	should_update_preview = FALSE

/datum/preference/numeric/tts_voice_pitch/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled || !SStts.pitch_enabled)
		return FALSE
	return ..()

/datum/preference/numeric/tts_voice_pitch/create_default_value()
	return 0

/datum/preference/numeric/tts_voice_pitch/apply_to_human(mob/living/carbon/human/target, value)
	if(SStts.tts_enabled && SStts.pitch_enabled)
		target.pitch = value

/datum/preference/choiced/tts_blip_base
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_blip_base"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	should_update_preview = FALSE

/datum/preference/choiced/tts_blip_base/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled)
		return FALSE
	return ..()

/datum/preference/choiced/tts_blip_base/init_possible_values()
	if(SStts.tts_enabled)
		return list("Masculine", "Feminine")
	return list("invalid")

/datum/preference/choiced/tts_blip_base/apply_to_human(mob/living/carbon/human/target, value)
	if(SStts.tts_enabled)
		if(value == "Masculine")
			target.blip_base = "male"
		else
			target.blip_base = "female"
	else
		target.blip_base = "male"

/datum/preference/choiced/tts_blip_base/create_default_value()
	return pick(list("Masculine", "Feminine"))

/datum/preference/numeric/tts_blip_number
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "tts_blip_number"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	minimum = 1
	maximum = 4
	should_update_preview = FALSE

/datum/preference/numeric/tts_blip_number/is_accessible(datum/preferences/preferences)
	if(!SStts.tts_enabled || !SStts.pitch_enabled)
		return FALSE
	return ..()

/datum/preference/numeric/tts_blip_number/create_default_value()
	return rand(1, 4)

/datum/preference/numeric/tts_blip_number/apply_to_human(mob/living/carbon/human/target, value)
	if(SStts.tts_enabled)
		target.blip_number = value
