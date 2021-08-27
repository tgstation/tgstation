/// The color of a PDA
/datum/preference/color/pda_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "pda_color"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/pda_color/create_default_value()
	return COLOR_OLIVE

/datum/preference/color/pda_color/apply_to_client(client/client, value)
	return

/// The visual style of a PDA
/datum/preference/choiced/pda_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "pda_style"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/pda_style/init_possible_values()
	return GLOB.pda_styles

/datum/preference/choiced/pda_style/apply_to_client(client/client, value)
	return
