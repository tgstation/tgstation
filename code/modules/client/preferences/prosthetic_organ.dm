/datum/preference/choiced/prosthetic_organ
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "prosthetic_organ"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/prosthetic_organ/create_default_value()
	return "Random"

/datum/preference/choiced/prosthetic_organ/init_possible_values()
	return list("Random") + GLOB.organ_choice

/datum/preference/choiced/prosthetic_organ/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Prosthetic Organ" in preferences.all_quirks

/datum/preference/choiced/prosthetic_organ/apply_to_human(mob/living/carbon/human/target, value)
	return
