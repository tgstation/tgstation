/datum/preference/choiced/enable_screentips
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "screentip_pref"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/enable_screentips/init_possible_values()
	return list(SCREENTIP_PREFERENCE_ENABLED, SCREENTIP_PREFERENCE_CONTEXT_ONLY, SCREENTIP_PREFERENCE_DISABLED)

/datum/preference/choiced/enable_screentips/create_default_value()
	return SCREENTIP_PREFERENCE_ENABLED

/datum/preference/choiced/enable_screentips/apply_to_client(client/client, value)
	client.mob?.hud_used?.screentips_enabled = value

/datum/preference/choiced/enable_screentips/deserialize(input, datum/preferences/preferences)
	// Migrate old always disabled screentips to context only.
	// Screentips were always meant to have context, though were initially merged without it.
	// This accepts that those users found screentips distracting, but gives a second chance now that
	// they provide a more obvious helping hand.
	// If they are still too distracting, there's nothing stopping them from disabling it again for good.
	if (input == FALSE)
		return ..(SCREENTIP_PREFERENCE_CONTEXT_ONLY, preferences)

	if (input == TRUE)
		return ..(SCREENTIP_PREFERENCE_ENABLED, preferences)

	return ..(input, preferences)

/datum/preference/color/screentip_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "screentip_color"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/screentip_color/apply_to_client(client/client, value)
	client.mob?.hud_used?.screentip_color = value

/datum/preference/color/screentip_color/create_default_value()
	return LIGHT_COLOR_FAINT_BLUE

/datum/preference/toggle/screentip_images
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "screentip_images"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/screentip_images/apply_to_client(client/client, value)
	client.mob?.hud_used?.screentip_images = value
