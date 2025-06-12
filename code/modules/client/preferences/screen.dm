/datum/preference/toggle/widescreen
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "widescreenpref"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/widescreen/apply_to_client(client/client, value)
	client.view_size?.setDefault(getScreenSize(value))

/datum/preference/toggle/fullscreen_mode
	default_value = FALSE
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "fullscreen_mode"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/fullscreen_mode/apply_to_client(client/client, value)
	//let's not apply unless the client is fully logged in, therefore manually triggering it.
	if(!client.fully_created)
		return
	client.set_fullscreen()
