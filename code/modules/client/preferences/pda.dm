/// The visual style of a PDA
/datum/preference/choiced/pda_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "pda_style"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/pda_style/init_possible_values()
	return GLOB.pda_styles

/datum/preference/choiced/pda_style/apply_to_client(client/client, value)
	return
