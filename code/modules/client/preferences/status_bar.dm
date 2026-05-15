/datum/preference/toggle/status_bar
	default_value = TRUE
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "status_bar"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/status_bar/apply_to_client(client/client, value)
	if(isnull(client) || istype(client, /datum/client_interface)) //no winset on mock clients.
		return
	winset(client, SKIN_MAPWINDOW_STATUS_BAR, "is-visible=[value]")
