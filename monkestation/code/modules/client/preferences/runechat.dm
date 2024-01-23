/datum/preference/toggle/enable_runechat_looc
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "see_looc_on_map"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/enable_runechat_looc/is_accessible(datum/preferences/preferences)
	return ..() && CONFIG_GET(flag/looc_enabled)
