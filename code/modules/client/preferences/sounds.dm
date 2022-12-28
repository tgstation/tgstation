/// Controls hearing ambience
/datum/preference/toggle/sound_ambience
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ambience"
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

/// Controls hearing dance machines
/datum/preference/toggle/sound_jukebox
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_jukebox"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/sound_jukebox/apply_to_client_updated(client/client, value)
	if (!value)
		client.mob.stop_sound_channel(CHANNEL_JUKEBOX)

/// Controls hearing lobby music
/datum/preference/toggle/sound_lobby
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_lobby"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/sound_lobby/apply_to_client_updated(client/client, value)
	if (value && isnewplayer(client.mob))
		client.playtitlemusic()
	else
		client.mob.stop_sound_channel(CHANNEL_LOBBYMUSIC)

/// Controls hearing admin music
/datum/preference/toggle/sound_midi
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_midi"
	savefile_identifier = PREFERENCE_PLAYER

/// Controls hearing ship ambience
/datum/preference/toggle/sound_ship_ambience
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "sound_ship_ambience"
	savefile_identifier = PREFERENCE_PLAYER
