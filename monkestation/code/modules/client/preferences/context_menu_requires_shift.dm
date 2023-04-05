
/datum/preference/toggle/context_menu_requires_shift
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "context_menu_requires_shift"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/context_menu_requires_shift/apply_to_client(client/client, value)
	client.context_menu_requires_shift = value
	client.set_right_click_menu_mode()
