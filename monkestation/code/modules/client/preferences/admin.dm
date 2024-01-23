/datum/preference/choiced/admin_hear_looc
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "admin_hear_looc"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/admin_hear_looc/init_possible_values()
	return list("Always", "When Observing", "Never")

/datum/preference/choiced/admin_hear_looc/create_default_value()
	return "Always"

/datum/preference/choiced/admin_hear_looc/is_accessible(datum/preferences/preferences)
	return ..() && is_admin(preferences.parent) && CONFIG_GET(flag/looc_enabled)
