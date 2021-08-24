/datum/preference/color/screentip_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "screentip_color"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/screentip_color/apply_to_client(client/client, value)
	client.mob?.hud_used?.screentip_color = value

/datum/preference/color/screentip_color/create_default_value()
	return "#ffd391"
