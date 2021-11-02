/datum/preference/numeric/tooltip_delay
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tip_delay"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 5000

/datum/preference/numeric/tooltip_delay/create_default_value()
	return 500

/datum/preference/toggle/enable_tooltips
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "enable_tips"
	savefile_identifier = PREFERENCE_PLAYER
