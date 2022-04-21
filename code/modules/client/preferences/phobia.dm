/datum/preference/choiced/phobia
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "phobia"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/phobia/init_possible_values()
	return GLOB.phobia_types

/datum/preference/choiced/phobia/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Phobia" in preferences.all_quirks

/datum/preference/choiced/phobia/apply_to_human(mob/living/carbon/human/target, value)
	return
