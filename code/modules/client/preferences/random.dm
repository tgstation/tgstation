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

/datum/preference/toggle/random_hardcore
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "random_hardcore"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	default_value = FALSE

/datum/preference/toggle/random_hardcore/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/toggle/random_hardcore/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return preferences.parent.get_exp_living(pure_numeric = TRUE) >= PLAYTIME_HARDCORE_RANDOM

/datum/preference/choiced/random_name
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "random_name"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/random_name/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/random_name/init_possible_values()
	return list(
		RANDOM_ANTAG_ONLY,
		RANDOM_DISABLED,
		RANDOM_ENABLED,
	)

/datum/preference/choiced/random_name/create_default_value()
	return RANDOM_DISABLED
