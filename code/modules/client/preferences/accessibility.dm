/// When toggled, being flashed will show a dark screen rather than a light one.
/datum/preference/toggle/darkened_flash
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "darkened_flash"
	savefile_identifier = PREFERENCE_PLAYER

/// When toggled, will not play surgery sounds for the client
/datum/preference/toggle/surgery_noise
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "surgery_noise"
	savefile_identifier = PREFERENCE_PLAYER

/// When toggled, will darken the screen on screen shake
/datum/preference/toggle/screen_shake_darken
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "screen_shake_darken"
	savefile_identifier = PREFERENCE_PLAYER
