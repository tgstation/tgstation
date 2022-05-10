/datum/preference/toggle/widescreen
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "widescreenpref"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/widescreen/apply_to_client(client/client, value)
	if(client?.prefs?.read_preference(/datum/preference/toggle/widescreen))
		INVOKE_ASYNC(client, /client.verb/SetWindowIconSize, client.prefs.icon_size)
	else
		client.view_size?.setDefault(getScreenSize(value))
