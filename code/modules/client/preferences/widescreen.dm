/datum/preference/toggle/widescreen
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "widescreenpref"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/widescreen/apply_to_client(client/client, value)
	client.view_size?.setDefault(getScreenSize(value))
