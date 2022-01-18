/// When toggled, will not play grav gen/telecomms sounds
/datum/preference/numeric/block_loud_sound
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "loud_sound"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 1
	maximum = 100

/datum/preference/numeric/block_loud_sound/create_default_value()
	return 100
