/// Controls ambience volume
/datum/preference/numeric/sound_ambience_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ambience_volume"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/// default value is max/2 because 100 1x modifier, while 200 is 2x
/datum/preference/numeric/sound_ambience_volume/create_default_value()
	return maximum/2

/datum/preference/numeric/sound_ambience_volume/apply_to_client(client/client, value)
	client.update_ambience_pref(value)

/datum/preference/toggle/sound_breathing
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_breathing"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls hearing announcement sounds
/datum/preference/toggle/sound_announcements
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_announcements"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls hearing the combat mode toggle sound
/datum/preference/toggle/sound_combatmode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_combatmode"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls hearing round end sounds
/datum/preference/toggle/sound_endofround
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_endofround"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls hearing instruments
/datum/preference/toggle/sound_instruments
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_instruments"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_tts
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_tts/init_possible_values()
	return list(TTS_SOUND_ENABLED, TTS_SOUND_BLIPS, TTS_SOUND_OFF)

/datum/preference/choiced/sound_tts/create_default_value()
	return TTS_SOUND_ENABLED

/datum/preference/numeric/sound_tts_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_volume"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/// default value is max/2 because 100 1x modifier, while 200 is 2x
/datum/preference/numeric/sound_tts_volume/create_default_value()
	return maximum/2

/datum/preference/choiced/sound_achievement
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_achievement"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_achievement/init_possible_values()
	return list(CHEEVO_SOUND_PING, CHEEVO_SOUND_JINGLE, CHEEVO_SOUND_TADA, CHEEVO_SOUND_OFF)

/datum/preference/choiced/sound_achievement/create_default_value()
	return CHEEVO_SOUND_PING

/datum/preference/choiced/sound_achievement/apply_to_client_updated(client/client, value)
	var/sound/sound_to_send = LAZYACCESS(GLOB.achievement_sounds, value)
	if(sound_to_send)
		SEND_SOUND(client.mob, sound_to_send)

/// Controls hearing dance machines
/datum/preference/toggle/sound_jukebox
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_jukebox"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/sound_jukebox/apply_to_client_updated(client/client, value)
	if (!value)
		client.mob.stop_sound_channel(CHANNEL_JUKEBOX)

/// Controls hearing lobby music
/datum/preference/numeric/sound_lobby_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_lobby_volume"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/// default value is max/2 because 100 1x modifier, while 200 is 2x
/datum/preference/numeric/sound_lobby_volume/create_default_value()
	return maximum/2

/datum/preference/numeric/sound_lobby_volume/apply_to_client_updated(client/client, value)
	if (value && isnewplayer(client.mob))
		client.playtitlemusic()
	else
		client.mob.stop_sound_channel(CHANNEL_LOBBYMUSIC)

/// Controls hearing admin music
/datum/preference/toggle/sound_midi
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_midi"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls ship ambience volume
/datum/preference/numeric/sound_ship_ambience_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ship_ambience_volume"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/// default value is max/2 because 100 1x modifier, while 200 is 2x
/datum/preference/numeric/sound_ship_ambience_volume/create_default_value()
	return maximum/2

/datum/preference/numeric/sound_ship_ambience_volume/apply_to_client_updated(client/client, value)
	client.mob.refresh_looping_ambience()

/// Controls hearing elevator music
/datum/preference/toggle/sound_elevator
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_elevator"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls radio noise volume
/datum/preference/numeric/sound_radio_noise
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_radio_noise"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/// default value is max/2 because 100 1x modifier, while 200 is 2x
/datum/preference/numeric/sound_radio_noise/create_default_value()
	return maximum/2

/// Controls hearing AI VOX announcements
/datum/preference/toggle/sound_ai_vox
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ai_vox"
	savefile_identifier = PREFERENCE_PLAYER
