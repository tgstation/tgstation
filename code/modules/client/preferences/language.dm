/datum/preference/choiced/language
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "language"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/language/init_possible_values()
	return GLOB.linguist_languages

/datum/preference/choiced/language/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Linguist" in preferences.all_quirks

/datum/preference/choiced/language/apply_to_human(mob/living/carbon/human/target, value)
	return
