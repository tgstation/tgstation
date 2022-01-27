/datum/preference/toggle/enable_screentips
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "screentip_pref"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/enable_screentips/apply_to_client(client/client, value)
	client.mob?.hud_used?.screentips_enabled = value

/datum/preference/color/screentip_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "screentip_color"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/screentip_color/apply_to_client(client/client, value)
	client.mob?.hud_used?.screentip_color = value

/datum/preference/color/screentip_color/create_default_value()
	return "#ffd391"
