/// When toggled, being flashed will show a dark screen rather than a light one.
/datum/preference/toggle/darkened_flash
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "darkened_flash"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/darkened_flash/apply_to_client(client/client, value)
	return
