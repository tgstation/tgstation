/datum/preference/choiced/linguist
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "linguist"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/linguist/init_possible_values()
	return GLOB.linguist_languages

/datum/preference/choiced/linguist/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Linguist" in preferences.all_quirks

/datum/preference/choiced/linguist/apply_to_human(mob/living/carbon/human/target, value)
	return
