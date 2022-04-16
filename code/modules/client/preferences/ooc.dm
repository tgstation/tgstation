/// The color admins will speak in for OOC.
/datum/preference/color/ooc_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "ooccolor"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/ooc_color/create_default_value()
	return "#c43b23"

/datum/preference/color/ooc_color/is_accessible(datum/preferences/preferences, applying_preference=FALSE)
	if (!..(preferences, applying_preference=applying_preference))
		return FALSE

	return is_admin(preferences.parent) || preferences.unlock_content
