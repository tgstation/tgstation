/datum/preference/choiced/glasses
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "glasses"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/glasses/init_possible_values()
	return GLOB.nearsighted_glasses

/datum/preference/choiced/glasses/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Nearsighted" in preferences.all_quirks

/datum/preference/choiced/glasses/apply_to_human(mob/living/carbon/human/target, value)
	return
