/datum/preference/choiced/atypical_tastes
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "atypical_tastes"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/atypical_tastes/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_quirk_atypical_tastes)

/datum/preference/choiced/atypical_tastes/create_default_value()
	return "Random"

/datum/preference/choiced/atypical_tastes/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Atypical Tastes" in preferences.all_quirks

/datum/preference/choiced/atypical_tastes/apply_to_human(mob/living/carbon/human/target, value)
	return
