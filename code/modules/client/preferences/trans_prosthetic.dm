/datum/preference/choiced/trans_prosthetic
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "trans_prosthetic"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/trans_prosthetic/create_default_value()
	return "Random"

/datum/preference/choiced/trans_prosthetic/init_possible_values()
	return list("Random") + GLOB.part_choice_transhuman

/datum/preference/choiced/trans_prosthetic/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Transhumanist" in preferences.all_quirks

/datum/preference/choiced/trans_prosthetic/apply_to_human(mob/living/carbon/human/target, value)
	return
