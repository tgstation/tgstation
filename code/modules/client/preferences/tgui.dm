/datum/preference/toggle/tgui_fancy
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_fancy"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/tgui_fancy/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.update_static_data(client.mob)

// Determines if input boxes are in tgui or old fashioned
/datum/preference/toggle/tgui_input
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_input"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/tgui_lock
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_lock"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_lock/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.update_static_data(client.mob)
