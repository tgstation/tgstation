/datum/preference/numeric/icon_size
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "icon_size"
	savefile_identifier = PREFERENCE_PLAYER

	minimum = 16
	maximum = 256 // Oh god, increase this if we start gaming with 16k monitors.

	step = 32

/datum/preference/numeric/icon_size/create_default_value()
	return 64

/* /datum/preference/numeric/icon_size/init_possible_values()
	return GLOBAL_LIST(valid_icon_sizes) */

/datum/preference/numeric/icon_size/apply_to_client(client/client, value)
	INVOKE_ASYNC(client, /client.verb/SetWindowIconSize, value)
