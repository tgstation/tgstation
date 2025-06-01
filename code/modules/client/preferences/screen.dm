/datum/preference/toggle/fullscreen_mode
	default_value = FALSE
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "fullscreen_mode"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/fullscreen_mode/apply_to_client(client/client, value)
	client.set_fullscreen()
