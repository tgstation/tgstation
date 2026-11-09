/datum/preference/toggle/auto_fit_viewport
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "auto_fit_viewport"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/auto_fit_viewport/apply_to_client_updated(client/client, value)
	INVOKE_ASYNC(client, TYPE_VERB_REF(/client, fit_viewport))
