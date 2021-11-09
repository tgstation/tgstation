/// Switches between middle, alt and right click for MODsuit active modules
/datum/preference/choiced/mod_select
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "mod_select"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/mod_select/init_possible_values()
	return list(MIDDLE_CLICK, ALT_CLICK, RIGHT_CLICK)

/datum/preference/choiced/mod_select/create_default_value()
	return MIDDLE_CLICK
