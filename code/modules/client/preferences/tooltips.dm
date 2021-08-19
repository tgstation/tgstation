/datum/preference/numeric/tooltip_delay
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tip_delay"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 5000

/datum/preference/numeric/tooltip_delay/create_default_value()
	return 500

// This preference is read by others, it does nothing on its own.
/datum/preference/numeric/tooltip_delay/apply_to_client(client/client, value)
	return

/datum/preference/toggle/enable_tooltips
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "enable_tips"
	savefile_identifier = PREFERENCE_PLAYER

// This preference is read by others, it does nothing on its own.
/datum/preference/toggle/enable_tooltips/apply_to_client(client/client, value)
	return
