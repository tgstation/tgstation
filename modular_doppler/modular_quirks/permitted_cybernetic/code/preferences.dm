/datum/preference/choiced/permitted_cybernetic
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "permitted_cybernetic"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/permitted_cybernetic/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_quirk_implants)

/datum/preference/choiced/permitted_cybernetic/create_default_value()
	return "Random"

/datum/preference/choiced/permitted_cybernetic/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Permitted Cybernetic" in preferences.all_quirks

/datum/preference/choiced/permitted_cybernetic/apply_to_human(mob/living/carbon/human/target, value)
	return
