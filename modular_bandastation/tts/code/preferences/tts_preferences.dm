/datum/preference/text/tts_seed
	savefile_key = "tts_seed"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODY_TYPE

/datum/preference/text/tts_seed/apply_to_human(mob/living/carbon/human/target, value)
	var/datum/tts_seed/seed = SStts220.tts_seeds[value]
	if(!seed)
		seed = SStts220.tts_seeds[SStts220.get_random_seed(target)]

	target.AddComponent(/datum/component/tts_component, seed)
	target.dna.tts_seed_dna = seed
	GLOB.human_to_tts["[target.real_name]"] = seed

/datum/preference/text/tts_seed/create_informed_default_value(datum/preferences/preferences)
	var/list/allowed_seeds = SStts220.get_available_seeds(preferences.parent)
	return SStts220.pick_tts_seed_by_gender(preferences.read_preference(/datum/preference/choiced/gender), allowed_seeds)

/datum/preference/text/tts_seed/deserialize(input, datum/preferences/preferences)
	var/datum/tts_seed/seed = SStts220.tts_seeds[input]
	if(!seed)
		return create_informed_default_value(preferences)
	var/list/allowed_seeds = SStts220.get_available_seeds(preferences.parent)
	if(!(seed.name in allowed_seeds))
		return create_informed_default_value(preferences)
	return input

/datum/preference/numeric/volume/sound_tts_volume_radio
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_volume_radio"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/datum/preference/numeric/volume/sound_tts_volume_radio/apply_to_client_updated(client/client, value)
	client.mob.set_sound_channel_volume(CHANNEL_TTS_RADIO, value)

/datum/preference/numeric/volume/sound_tts_volume_radio/create_default_value()
	return maximum / 2

/datum/preference/numeric/volume/sound_tts_volume_announcement
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_volume_announcement"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/datum/preference/numeric/volume/sound_tts_volume_announcement/apply_to_client_updated(client/client, value)
	client.mob.set_sound_channel_volume(CHANNEL_TTS_ANNOUNCEMENT, value)

/datum/preference/numeric/volume/sound_tts_volume_announcement/create_default_value()
	return maximum / 2

/datum/preference/numeric/volume/sound_tts_volume_telepathy
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_volume_telepathy"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/datum/preference/numeric/volume/sound_tts_volume_telepathy/apply_to_client_updated(client/client, value)
	client.mob.set_sound_channel_volume(CHANNEL_TTS_TELEPATHY, value)

/datum/preference/numeric/volume/sound_tts_volume_telepathy/create_default_value()
	return maximum / 2
