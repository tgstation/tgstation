// MOTHBLOCKS TODO: Don't show this when you're not an admin.
// MOTHBLOCKS TODO: Don't show this when allow_admin_asaycolor is not enabled.
/datum/preference/color/asay_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "asaycolor"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/asay_color/apply_to_client(client/client, value)
	return

/datum/preference/color/asay_color/create_default_value()
	return DEFAULT_ASAY_COLOR
