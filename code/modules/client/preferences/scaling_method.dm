/// The scaling method to show the world in, e.g. nearest neighbor
/datum/preference/choiced/scaling_method
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "scaling_method"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/scaling_method/create_default_value()
	return SCALING_METHOD_DISTORT

/datum/preference/choiced/scaling_method/init_possible_values()
	return list(SCALING_METHOD_DISTORT, SCALING_METHOD_BLUR, SCALING_METHOD_NORMAL)

/datum/preference/choiced/scaling_method/apply_to_client(client/client, value)
	client?.view_size?.setZoomMode()
