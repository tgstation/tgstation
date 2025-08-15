/datum/preference/numeric/volume
	abstract_type = /datum/preference/numeric/volume
	minimum = 0
	maximum = 100

/datum/preference/numeric/volume/create_default_value()
	return maximum

/// Controls ambience volume
/datum/preference/numeric/volume/sound_ambience_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ambience_volume"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_ambience_volume/apply_to_client(client/client, value)
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

/// Controls hearing the combat mode sound
/datum/preference/toggle/sound_combatmode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_combatmode"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls hearing instruments
/datum/preference/numeric/volume/sound_instruments
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_instruments"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls jukebox track volume
/datum/preference/numeric/volume/sound_jukebox
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_jukebox"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_jukebox/apply_to_client_updated(client/client, value)
	var/mob/client_mob = client.mob
	if(!isnull(client_mob))
		SEND_SIGNAL(client_mob, COMSIG_MOB_JUKEBOX_PREFERENCE_APPLIED)

/datum/preference/choiced/sound_tts
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_tts/init_possible_values()
	return list(TTS_SOUND_ENABLED, TTS_SOUND_BLIPS, TTS_SOUND_OFF)

/datum/preference/choiced/sound_tts/create_default_value()
	return TTS_SOUND_ENABLED

/datum/preference/numeric/volume/sound_tts_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_tts_volume"
	savefile_identifier = PREFERENCE_PLAYER

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

/// Controls hearing lobby music
/datum/preference/numeric/volume/sound_lobby_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_lobby_volume"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_lobby_volume/apply_to_client_updated(client/client, value)
	if (value && isnewplayer(client.mob))
		client.playtitlemusic()
	else
		client.mob.stop_sound_channel(CHANNEL_LOBBYMUSIC)

/// Controls hearing admin music
/datum/preference/numeric/volume/sound_midi
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_midi"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls ship ambience volume
/datum/preference/numeric/volume/sound_ship_ambience_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ship_ambience_volume"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/numeric/volume/sound_ship_ambience_volume/apply_to_client_updated(client/client, value)
	client.mob.refresh_looping_ambience()

/// Controls radio noise volume
/datum/preference/numeric/volume/sound_radio_noise
	savefile_key = "sound_radio_noise"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls hearing AI VOX announcements
/datum/preference/numeric/volume/sound_ai_vox
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ai_vox"
	savefile_identifier = PREFERENCE_PLAYER

/// Choice of which ghost poll prompt to use
/datum/preference/choiced/sound_ghost_poll_prompt
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ghost_poll_prompt"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/sound_ghost_poll_prompt/create_default_value()
	return GHOST_POLL_PROMPT_1

/datum/preference/choiced/sound_ghost_poll_prompt/init_possible_values()
	return list(GHOST_POLL_PROMPT_DISABLED, GHOST_POLL_PROMPT_1, GHOST_POLL_PROMPT_2)

/// Volume which ghost poll prompts are played at
/datum/preference/numeric/sound_ghost_poll_prompt_volume
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ghost_poll_prompt_volume"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 200

/// default value is max/2 because 100 1x modifier, while 200 is 2x
/datum/preference/numeric/sound_ghost_poll_prompt_volume/create_default_value()
	return maximum/2
