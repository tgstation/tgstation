GLOBAL_DATUM_INIT(roundend_hidden_ckeys, /alist, alist())

/datum/preference/toggle/hide_roundend_ckey
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "hide_roundend_ckey"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = FALSE

/datum/preference/toggle/hide_roundend_ckey/apply_to_client(client/client, value)
	GLOB.roundend_hidden_ckeys[client.ckey] = value
