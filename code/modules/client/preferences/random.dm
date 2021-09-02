/datum/preference/choiced/random_body
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "random_body"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/random_body/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/random_body/init_possible_values()
	return list(
		RANDOM_ANTAG_ONLY,
		RANDOM_DISABLED,
		RANDOM_ENABLED,
	)

/datum/preference/choiced/random_body/create_default_value()
	return RANDOM_DISABLED
