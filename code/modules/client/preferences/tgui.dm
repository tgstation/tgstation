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

/// Large button preference. Error text is in tooltip.
/datum/preference/toggle/tgui_input_large
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_input_large"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_input_large/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.send_full_update(client.mob)

/// Swapped button state - sets buttons to SS13 traditional SUBMIT/CANCEL
/datum/preference/toggle/tgui_input_swapped
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_input_swapped"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/tgui_input_swapped/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.send_full_update(client.mob)

/datum/preference/toggle/tgui_lock
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_lock"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_lock/apply_to_client(client/client, value)
	for (var/datum/tgui/tgui as anything in client.mob?.tgui_open_uis)
		// Force it to reload either way
		tgui.update_static_data(client.mob)

/// Light mode for tgui say
/datum/preference/toggle/tgui_say_light_mode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "tgui_say_light_mode"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/tgui_say_light_mode/apply_to_client(client/client)
	client.tgui_say?.load()
