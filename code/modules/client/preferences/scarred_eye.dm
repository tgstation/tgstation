/datum/preference/choiced/scarred_eye
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "scarred_eye"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/scarred_eye/init_possible_values()
	return GLOB.scarred_eye_choice

/datum/preference/choiced/scarred_eye/create_default_value()
	return "Random"

/datum/preference/choiced/scarred_eye/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Scarred Eye" in preferences.all_quirks

/datum/preference/choiced/scarred_eye/apply_to_human(mob/living/carbon/human/target, value)
	return
