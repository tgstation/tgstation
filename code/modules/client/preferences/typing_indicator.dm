/// Whether or not to show a typing indicator when speaking. Defaults to on.
/datum/preference/toggle/typing_indicator
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "typingindicator"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/typing_indicator/apply_to_client(client/client, value)
	client?.typing_indicators = value
