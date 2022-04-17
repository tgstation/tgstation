/datum/preference/color/heterochromatic
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "heterochromatic"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/color/heterochromatic/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Heterochromatic" in preferences.all_quirks
