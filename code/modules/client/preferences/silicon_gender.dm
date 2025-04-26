/datum/preference/choiced/silicon_gender
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "silicon_gender"

/datum/preference/choiced/silicon_gender/init_possible_values()
	return list("Use gender", MALE, FEMALE, PLURAL, NEUTER)

/datum/preference/choiced/silicon_gender/create_default_value()
	return "Use gender"

/datum/preference/choiced/silicon_gender/apply_to_human(mob/living/carbon/human/target, value)
	return
