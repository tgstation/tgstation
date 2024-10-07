/datum/preference/choiced/implanted_quirk
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "implanted_quirk"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/implanted_quirk/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_quirk_implants)

/datum/preference/choiced/implanted_quirk/create_default_value()
	return "Random"

/datum/preference/choiced/implanted_quirk/is_accessible(datum/preferences/preferences)
	if (!..())
		return FALSE

	return "Implanted" in preferences.all_quirks

/datum/preference/choiced/implanted_quirk/apply_to_human(mob/living/carbon/human/target, value)
	return
