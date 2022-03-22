/datum/preference/toggle/hotkeys
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "hotkeys"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/hotkeys/apply_to_client(client/client, value)
	client.hotkeys = value
