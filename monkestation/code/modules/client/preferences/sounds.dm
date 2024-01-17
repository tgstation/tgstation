/datum/preference/toggle/sound_vox
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE
	savefile_key = "sound_vox"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/sound_vox/apply_to_client_updated(client/client, value)
	. = ..()
	if (!value)
		client.mob?.stop_sound_channel(CHANNEL_VOX)
