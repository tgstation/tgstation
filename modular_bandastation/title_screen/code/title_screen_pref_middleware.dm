// This is purely so that we can cleanly update the name in the "Setup Character" menu entry.
/datum/preference_middleware/titlescreen

/datum/preference_middleware/titlescreen/on_new_character(mob/user)
	// User changed the slot.
	if(!istype(user, /mob/dead/new_player))
		return

	SStitle.update_character_name(user, preferences.read_preference(/datum/preference/name/real_name))

/datum/preference_middleware/titlescreen/post_set_preference(mob/user, preference, value)
	// User changed the current slot's name.
	if(!istype(user, /mob/dead/new_player) || preference != "real_name")
		return FALSE

	SStitle.update_character_name(user, value)
	return TRUE

// Title Screen Preferences
/datum/preference/choiced/lobby_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "lobby_style"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/lobby_style/init_possible_values()
	return assoc_to_keys(GLOB.available_lobby_styles)

/datum/preference/choiced/lobby_style/create_default_value()
	return GLOB.available_lobby_styles[1]

/datum/preference/choiced/lobby_style/apply_to_client(client/client, value)
	client.fix_title_screen()
