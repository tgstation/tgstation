/datum/preference/numeric/pixel_size
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "pixel_size"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 0
	maximum = 5

	step = 0.5

/datum/preference/numeric/pixel_size/create_default_value()
	return 0

/datum/preference/numeric/pixel_size/apply_to_client(client/client, value)
	client?.view_size?.resetFormat()
