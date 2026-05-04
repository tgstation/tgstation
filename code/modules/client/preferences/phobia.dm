/datum/preference/choiced/phobia
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "phobia"
	savefile_identifier = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/phobia/init_possible_values()
	return GLOB.phobia_types

/datum/preference/choiced/phobia/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return /datum/brain_trauma/mild/phobia::name in preferences.all_quirks

/datum/preference/choiced/phobia/apply_to_human(mob/living/carbon/human/target, value)
	return
